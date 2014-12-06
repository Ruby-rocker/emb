Yostalgia.CoverPhotoSelectorModalController = Yostalgia.ObjectController.extend

  needs: ['photoSelectorList']

  user: Ember.computed.alias('session.user')
  profile: Ember.computed.alias('user.profile')
  photoList: Ember.computed.alias('controllers.photoSelectorList')

  selectedPhoto: null
  newPhotoFile: null
  isSaving: false
  morePages: false

  albumName: null
  generalAlbumImage: null

  actions:

    save: ->
      # if new photo then upload (back-end updates automatically)
      if !@blank 'newPhotoFile'
        @set 'isSaving', true
        @get('profile').then (profile) =>
          newPhoto = @get('store').createRecord('attachment')
          newPhoto.set 'user', @get('user')
          newPhoto.set 'attachable', profile
          newPhoto.set 'fpFile', @get('newPhotoFile')
          newPhoto.set 'subType', 'cover_photo'
          newPhoto.save().then =>
            @set 'isSaving', false
            @send 'close'
            @transitionToRoute 'user.index' # navigate back to today (noop if already there)
          , (error) =>
            @set 'isSaving', false
            @send 'pushAlert', 'alert', 'Uh-oh!', "We couldn't save your cover photo. Please try again"
            console.log error

      # if existing photo then save profile
      else if !@blank 'selectedPhoto'
        @set 'isSaving', true
        @get('profile').then (profile) =>
          profile.set 'coverPhoto', @get('selectedPhoto')
          profile.save().then =>
            @set 'isSaving', false
            @send 'close'
            @transitionToRoute 'user.index' # navigate back to today (noop if already there)
          , (error) =>
            @set 'isSaving', false
            @send 'pushAlert', 'alert', 'Uh-oh!', "We couldn't save your cover photo. Please try again"
            console.log error

      else
        @send 'pushAlert', 'alert', 'Oops', 'You must select or upload a photo to save'

    clearSelected: ->
      @set 'selectedPhoto', null
      @set 'newPhotoFile', null

    reset: ->
      @set 'model', []
      @set 'selectedPhoto', null
      @set 'newPhotoFile', null
      @set 'albumName', null
      @set 'profileAlbumImage', @get('user.profile.photo')
      @get('store').find('attachment', user_id: @get('user.id'), limit: 1).then (photos) =>
        @set 'generalAlbumImage', photos.get('firstObject')
      @get('store').find('attachment', yostalgia_covers: true).then (photos) =>
        @set 'yostalgiaCoverAlbumImage', photos.get('firstObject')

    backToAlbumList: ->
      @set 'albumName', null
      @set 'selectedPhoto', null

    showCoverPhotoAlbum: ->
      @set 'albumName', 'cover'
      @set 'page', 1
      @send 'loadPhotoAlbum'

    showProfilePhotoAlbum: ->
      @set 'albumName', 'profile'
      @set 'page', 1
      @send 'loadPhotoAlbum'

    showGeneralPhotoAlbum: ->
      @set 'albumName', 'other'
      @set 'page', 1
      @send 'loadPhotoAlbum'

    showYostalgiaCoverAlbum: ->
      @set 'albumName', 'yostalgia'
      @set 'page', 1
      @send 'loadPhotoAlbum'

    loadPhotoAlbum: ->
      photoList = @get('photoList')
      photoList.set 'model', Ember.A()
      photoList.set 'isLoading', true
      @get('store').find('attachment', @get('attachmentSearchOptions')).then (photos) =>
        photos.forEach (photo) =>
          @get('photoList').pushObject photo
        photoList.set 'isLoading', false
        @send 'setMetaData', photos

    loadNextAlbumPage: ->
      if @get('morePages') && !@get('isLoading')
        @set 'isLoading', true
        photoList = @get('photoList')
        @set 'page', @get('page') + 1
        @get('store').find('attachment', @get('attachmentSearchOptions')).then (photos) =>
          photos.forEach (photo) =>
            @get('photoList').pushObject photo
          @set 'isLoading', false
          @send 'setMetaData', photos

    setMetaData: (photos) ->
      metadata = photos.meta
      @set 'page', metadata.page
      @set 'morePages', if metadata.more_pages == 'yes' then true else false

    close: ->
      @send 'closeModal'


  showAlbumList: (->
    @blank('albumName') && @blank('newPhotoFile')
  ).property('albumName', 'newPhotoFile')

  showPhotoList: (->
    @get('albumName') && !@get('selectedPhoto') && !@get('newPhotoFile')
  ).property('albumName', 'selectedPhoto', 'newPhotoFile')

  showUploadButton: (->
    @blank('selectedPhoto') && @blank('newPhotoFile')
  ).property('selectedPhoto', 'newPhotoFile')

  showSaveButton: (->
    !@get('isSaving') && (!@blank('selectedPhoto') || !@blank('newPhotoFile'))
  ).property('selectedPhoto', 'newPhotoFile', 'isSaving')

  showCoverPhotoAlbum: (->
    @get('user.coverPhotoCount') > 0
  ).property('user.coverPhotoCount')

  showProfilePhotoAlbum: (->
    @get('user.profilePhotoCount') > 0
  ).property('user.profilePhotoCount')

  showGeneralPhotoAlbum: (->
    @get('user.generalPhotoCount') > 0
  ).property('user.generalPhotoCount')

  showYostalgiaCoversAlbum: (->
    !@blank 'yostalgiaCoverAlbumImage'
  ).property('yostalgiaCoverAlbumImage')


  albumTitle: (->
    album = @get('albumName')

    if album == 'cover'
      'Cover Photos'
    else if album == 'profile'
      'Profile Photos'
    else if album == 'other'
      'Your Photos'
    else if album == 'yostalgia'
      'Yostalgia Photos'
  ).property('albumName')

  attachmentSearchOptions: (->
    album = @get('albumName')
    page = @get('page')
    userId = @session.get('user.id')

    if album == 'cover'
      { cover_photos: true, user_id: userId, page: page }
    else if album == 'profile'
      { profile_photos: true, user_id: userId, page: page }
    else if album == 'other'
      { user_id: @session.get('user.id'), page: page }
    else if album == 'yostalgia'
      { yostalgia_covers: true }
  ).property('albumName', 'page')
