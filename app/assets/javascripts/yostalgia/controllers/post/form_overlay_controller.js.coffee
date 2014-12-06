Yostalgia.PostFormOverlayController = Yostalgia.OverlayController.extend

  needs: ['application']

  mentionsSearchResults: Ember.A()

  files: []
  selectedFriends: []
  isSaving: false

  showPrivateToggle: true

  create: ->
    post = @get('store').createRecord('post')
    @set('model', post)

  ### actions ###

  actions:
    mentionsSearch: (term) ->
      unless Ember.isEmpty term
        @store.find('user', search: term, friends: true).then (users) =>
          @set 'mentionsSearchResults', users

    save: ->
      return if !@validate()
      return if @get 'isSaving'

      @set 'isSaving', true

      taggedUsers = @get 'model.taggedUsers'
      taggedUsers.clear()
      taggedUsers.addObjects @get('selectedFriends')

      @get('model').save().then (post) =>
        files = @get('files')
        attachments = []

        files.forEach (file) =>
          attachment = @get('store').createRecord('attachment')
          attachment.set 'fpFile', file
          attachment.set 'attachable', post
          attachments.pushObject attachment

        Ember.RSVP.all(attachments.invoke('save')).then =>
          @send 'pushAlert', 'success', 'Post saved'
          @set 'isSaving', false
          @set 'files', []
          @send 'close'
          currentRoute = @get 'controllers.application.currentRouteName'
          if post.get('event')
            if currentRoute != 'event.posts'
              @transitionToRoute 'event.posts', post.get('event')
          else
            if currentRoute == 'newsfeed.index'
              @send 'reloadNewsfeed'
            else
              @transitionToRoute 'newsfeed'
        , (error) =>
          @send 'pushAlert', 'alert', 'Uh-oh', "We couldn't save your photos :("
          @set 'isSaving', false
          console.log error

      , (error) =>
        @send 'pushAlert', 'alert', 'Uh-oh', "We couldn't save your post :("
        @set 'isSaving', false
        console.log error

    removeAttachment: (fileToRemove) ->
      files = @get 'files'
      @set 'files', files.reject (file) ->
        file == fileToRemove

    selectFriends: (selectedFriends) ->
      @set 'selectedFriends', selectedFriends
      console.log @get('selectedFriends')

    removeFriend: (friendToRemove) ->
      selectedFriends = @get 'selectedFriends'
      @set 'selectedFriends', selectedFriends.reject (friend) ->
        friend == friendToRemove

    addVideo: ->
      alert 'coming soon...'

    addVlog: ->
      alert 'coming soon...'

    close: ->
      @_super()
      files = @get 'files'
      files.forEach (file) ->
        filepicker.remove file
      @set 'files', []
      @set 'selectedFriends', []

  # properties

  submitDisabled: (->
    @get 'isSaving'
  ).property('isSaving')

  buttonText: (->
    return if @get('isSaving') then "Saving..." else "Post it!"
  ).property('isSaving')

  availableFriends: (->
    if taggedUsers = @get('taggedUsers')
      taggedUsers.forEach (user) ->
        user.set 'isSelected', true
    @get('session.user.friends')
  ).property('session.user.friends.@each', 'taggedUsers.@each')


  # validation

  validate: ->
    if !@get('files.length') and @blank('body')
      @set 'bodyValidationReason', 'You must enter some text or add a photo to post'
      return false
    true

  bodyValidation: (->
    if @get('bodyValidationReason') and @blank('body') and !@get('files.length')
      return Yostalgia.InputValidation.create
        failed: true
        reason: @get 'bodyValidationReason'

    Yostalgia.InputValidation.create(ok: true)
  ).property('body', 'bodyValidationReason', 'files.length')


  # attributes

  postedAtDisplay: (->
    if @blank('postedAt') then @set('postedAt', moment())
    Yostalgia.Utilities.simpleDateDisplay(@get('postedAt'))
  ).property('postedAt')
