Yostalgia.SignupStep2Controller = Yostalgia.ObjectController.extend

  # TODO: remove duplication between this and EditUserController

  validationReason: null
  isSaving: false

  ### actions ###

  actions:
    changeGender: (gender) ->
      @set('gender', gender)

    completeStep: ->
      @validate()
      return if !@blank 'validationReason'

      profile = @get('model')

      @get('photo').then (photo) =>

        if !profile.get('isDirty') && !photo.get('isDirty')
          @transitionToRoute 'index'
          return

        @set 'isSaving', true
        itemsToSave = []

        if profile.get('isDirty')
          profile.on 'didError', =>
            @send 'pushAlert', 'alert', 'Uh-oh', "We couldn't save your profile"
            profile.rollback()
          itemsToSave.pushObject profile

        if photo.get('isDirty') && photo.get('url')
          newPhoto = @get('store').createRecord('attachment', photo._attributes)
          newPhoto.set 'attachable', profile
          newPhoto.on 'didUpdate', ->
            photo.rollback()
          newPhoto.on 'didError', =>
            @send 'pushAlert', 'alert', 'Uh-oh', "We couldn't save your photo"
            photo.rollback()
            newPhoto.deleteRecord()
          itemsToSave.pushObject newPhoto

        Ember.RSVP.all(itemsToSave.invoke('save')).then =>
          @set 'isSaving', false
          @transitionToRoute 'signup.step_3'

  ### properties ###

  submitDisabled: (->
    return true if @get 'isSaving'
    return true if !@blank 'validationReason'
    false
  ).property('isSaving', 'validationReason')

  validationTip: (->
    if @blank 'validationReason'
      return Yostalgia.InputValidation.create(ok: true)

    Yostalgia.InputValidation.create
      failed: true
      reason: @get 'validationReason'
  ).property('validationReason')

  updateValidationTip: (->
    @validate() if !@blank 'validationReason'
  ).observes('dateOfBirth', 'gender')

  # TODO: this seems wrong somehow, is there a better way to handle timezones?
  dateOfBirth: ((key, value) ->
    if arguments.length == 2 and value
      m = moment(value)
      correctedDate = new Date(Date.UTC(m.year(), m.month(), m.date()))
      @set 'model.dateOfBirth', correctedDate

    @get 'model.dateOfBirth'
  ).property('model.dateOfBirth')

  ### methods ###

  validate: ->
    reasons = []
    reasons.push 'date of birth' if @blank 'dateOfBirth'
    reasons.push 'gender' if @blank 'gender'
    if reasons.length > 0
      @set 'validationReason', "Please provide your #{reasons.join(' and ')}."
    else
      @set 'validationReason', null
