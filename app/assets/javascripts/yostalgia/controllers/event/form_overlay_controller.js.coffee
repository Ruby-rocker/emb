Yostalgia.EventFormOverlayController = Yostalgia.OverlayController.extend

  titleValidationMessage: null
  bodyValidationMessage: null
  startTimeValidationMessage: null
  endTimeValidationMessage: null

  coverPhotoFile: null
  selectedFriends: null

  isSaving: false

  mentionsSearchResults: Ember.A()

  create: ->
    newEvent = @get('store').createRecord('event')
    @set('model', newEvent)


  ### actions ###

  actions:
    mentionsSearch: (term) ->
      unless Ember.isEmpty term
        @store.find('user', search: term, friends: true).then (users) =>
          @set 'mentionsSearchResults', users

    close: ->
      @_super()
      @set 'selectedFriends', null
      filepicker.remove(@get('coverPhotoFile')) if !@blank 'coverPhotoFile'
      @set 'coverPhotoFile', null
      @set 'isSaving', false

    save: ->
      @send('validate')
      return if !@get('isValid') or @get('isSaving')

      @set 'isSaving', true

      @get('model').save().then (savedEvent) =>
        itemsToSave = []

        coverPhoto = @get('store').createRecord('attachment', subType: 'event_photo')
        coverPhoto.set 'fpFile', @get('coverPhotoFile')
        coverPhoto.set 'attachable', savedEvent
        itemsToSave.push coverPhoto

        selectedFriends = @get 'selectedFriends'
        if !Ember.isEmpty(selectedFriends) && selectedFriends.length
          selectedFriends.forEach (selectedFriend) =>
            invite = @get('store').createRecord('eventInvitation')
            invite.set 'user', selectedFriend
            invite.set 'event', savedEvent
            itemsToSave.pushObject invite

        Ember.RSVP.all(itemsToSave.invoke('save')).then =>
          @send 'pushAlert', 'success', 'Event saved!'
          @set 'isSaving', false
          @set 'coverPhotoFile', null
          @send 'close'
          @transitionToRoute 'event', this

      , (error) =>
        @send 'pushAlert', 'alert', 'Uh-oh', "We couldn't save your event :-("
        @set 'isSaving', false
        console.log error

    selectFriends: (selectedFriends) ->
      @set 'selectedFriends', selectedFriends

    removeFriend: (friendToRemove) ->
      selectedFriends = @get 'selectedFriends'
      @set 'selectedFriends', selectedFriends.reject (friend) ->
        friend == friendToRemove

    validate: ->
      if @blank 'title'
        @set 'titleValidationMessage', 'You need to set a title to create an event'
      else @set 'titleValidationMessage', null

      if @blank 'body'
        @set 'bodyValidationMessage', 'You need to add a description of your event'
      else
        @set 'bodyValidationMessage', null

      if @blank 'startTime'
        @set 'startTimeValidationMessage', 'You need to let people know the date of your event'
      else
        @set 'startTimeValidationMessage', null

      if @get('endTime') < @get('startTime')
        @set 'endTimeValidationMessage', "Oops, your event can't end before it has started!"
      else
        @set 'endTimeValidationMessage', null

      if @blank 'coverPhotoFile'
        @set 'coverPhotoValidationMessage', 'You need to select a cover photo to create an event'
      else
        @set 'coverPhotoValidationMessage', null

  ### properties ###

  isValid: (->
    return false if !@blank 'titleValidationMessage'
    return false if !@blank 'bodyValidationMessage'
    return false if !@blank 'startTimeValidationMessage'
    return false if !@blank 'endTimeValidationMessage'
    return false if !@blank 'coverPhotoValidationMessage'
    true
  ).property(
    'titleValidationMessage',
    'bodyValidationMessage',
    'startTimeValidationMessage',
    'endTimeValidationMessage',
    'coverPhotoValidationMessage')

  submitDisabled: (->
    'disabled' if !@get('isValid') || @get('isSaving')
  ).property('isValid', 'isSaving')

  buttonText: (->
    return if @get('isSaving') then "Saving..." else "Post it!"
  ).property('isSaving')

  availableFriends: (->
    if selecetedFriends = @get('selectedFriends')
      selecetedFriends.forEach (friend) ->
        friend.set 'isSelected', true
    @session.get('user.friends')
  ).property('session.user.friends.@each', 'selectedFriends.@each')

  startTimeDate: ((key, value) ->
    if arguments.length == 2 && value
      if !@blank('model.startTime')
        hours = @get('model.startTime').getHours()
        minutes = @get('model.startTime').getMinutes()
      else
        hours = 18
        minutes = 0
      newDate = moment(value).hour(hours).minutes(minutes).seconds(0).toDate()
      @set('model.startTime', newDate)

      if @blank('model.endTime')
        newEndDate = moment(newDate).add('hours', 4).toDate()
        @set('model.endTime', newEndDate)

    @get('model.startTime')
  ).property('model.startTime')

  startTimeTime: ((key, value) ->
    if arguments.length == 2 && value
      newTime = chrono.parseDate(value, @get('model.startTime'))
      @set('model.startTime', newTime) if newTime

    if !@blank('model.startTime')
      moment(@get('model.startTime')).format('h:mm a')
    else
      null
  ).property('model.startTime')

  endTimeDate: ((key, value) ->
    if arguments.length == 2 && value
      if !@blank('model.endTime')
        hours = @get('model.endTime').getHours()
        minutes = @get('model.endTime').getMinutes()
      else
        hours = 18
        minutes = 0
      newDate = moment(value).hour(hours).minutes(minutes).seconds(0).toDate()
      @set('model.endTime', newDate)

    @get('model.endTime')
  ).property('model.endTime')

  endTimeTime: ((key, value) ->
    if arguments.length == 2 && value
      newTime = chrono.parseDate(value, @get('model.endTime'))
      @set('model.endTime', newTime) if newTime

    if !@blank('model.endTime')
      moment(@get('model.endTime')).format('h:mm a')
    else
      null
  ).property('model.endTime')

  ### observers ###

  clearTitleValidationMessage: (->
    if !@blank('titleValidationMessage') && !@blank('title')
      @set 'titleValidationMessage', null
  ).observes('title')

  clearBodyValidationMessage: (->
    if !@blank('bodyValidationMessage') && !@blank('body')
      @set 'bodyValidationMessage', null
  ).observes('body')

  clearStartTimeValidationMessage: (->
    if !@blank('startTimeValidationMessage') && !@blank('startTime')
      @set 'startTimeValidationMessage', null
  ).observes('startTime')

  clearEndTimeValidationMessage: (->
    if !@blank('endTimeValidationMessage') && @get('endTime') > @get('startTime')
      @set 'endTimeValidationMessage', null
  ).observes('endTime')

  clearCoverPhotoValidationMessage: (->
    if !@blank('coverPhotoValidationMessage') && !@blank('coverPhotoFile')
      @set 'coverPhotoValidationMessage', null
  ).observes('coverPhotoFile')
