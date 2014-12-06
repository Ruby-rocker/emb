Yostalgia.UserEditController = Yostalgia.OverlayController.extend

  # TODO: remove duplication between this and EditUserController

  validationReason: null
  isSaving: false

  ### actions ###

  actions:
    close: ->
      model = @get('model')
      model.rollback() if model

      if model.get('photo')
        model.get('photo').then (photo) =>
          photo.rollback()

      @send 'closeOverlay'

    edit: (record) ->
      @_super(record)

      if !record.get('photo')
        record.set 'photo', @get('store').createRecord('attachment')

    changeGender: (gender) ->
      @set('gender', gender)

    save: ->
      @validate()
      return if @get 'submitDisabled'

      if !@get('isDirty') && !@get('photo.isDirty')
        @send 'close'
        return

      profile = @get('model')

      @get('photo').then (photo) =>

        if !profile.get('isDirty') && !photo.get('isDirty')
          @send 'close'
          return

        @set 'isSaving', true
        itemsToSave = []

        if profile.get('isDirty')
          profile.on 'didError', =>
            @send 'pushAlert', 'alert', 'Uh-oh!', "we couldn't save your profile"
            profile.rollback()
          itemsToSave.pushObject profile

        if photo.get('isDirty') && photo.get('url')
          newPhoto = @get('store').createRecord('attachment', photo._attributes)
          newPhoto.set 'attachable', profile
          newPhoto.on 'didUpdate', ->
            photo.rollback()
          newPhoto.on 'didError', =>
            @send 'pushAlert', 'alert', 'Uh-oh!', "we couldn't save your photo"
            photo.rollback()
            newPhoto.deleteRecord()
          itemsToSave.pushObject newPhoto

        Ember.RSVP.all(itemsToSave.invoke('save')).then =>
          @set 'isSaving', false
          @send 'close'


  ### properties ###

  submitDisabled: (->
    return true if @get 'isSaving'
    return true if @get 'firstNameValidation.failed'
    return true if @get 'lastNameValidation.failed'
    return true if !@blank 'validationReason'
    false
  ).property(
    'isSaving',
    'validationReason',
    'firstNameValidation.failed',
    'lastNameValidation.failed')

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

  firstNameValidation: (->
    if @blank 'firstName'
      return Yostalgia.InputValidation.create
        failed: true
        reason: "can't be blank"

    return Yostalgia.InputValidation.create(ok: true)
  ).property('firstName')

  lastNameValidation: (->
    if @blank 'lastName'
      return Yostalgia.InputValidation.create
        failed: true
        reason: "can't be blank"

    return Yostalgia.InputValidation.create(ok: true)
  ).property('lastName')


  ### methods ###

  validate: ->
    reasons = []
    reasons.push 'date of birth' if @blank 'dateOfBirth'
    reasons.push 'gender' if @blank 'gender'
    if reasons.length > 0
      @set 'validationReason', "Please provide your #{reasons.join(' and ')}."
    else
      @set 'validationReason', null
