Yostalgia.NotificationMentionController = Yostalgia.NotificationBaseController.extend

  actions:
    transitionToItem: ->
      type = @get 'redirectType'
      model = @get 'redirectModel'

      if type == 'attachment'
        if model.get('isPostAttachment') && model.get('attachable.hasMediaGroup')
          @transitionToRoute 'post.attachment', model.get('attachable'), model
        else if model.get 'isPostAttachment'
          @transitionToRoute 'post', model.get('attachable')

        if model.get 'isProfileAttachment'
          @transitionToRoute 'profile_photos.photo', model.get('attachable.user'), model.get('id')
        if model.get 'isCoverPhotoAttachment'
          @transitionToRoute 'cover_photos.photo', model.get('attachable.user'), model.get('id')
      else
        @transitionToRoute type, model

  trackableType: (->
    Yostalgia.Utilities.constructorToString @get('trackable.constructor')
  ).property('trackable')

  trackableTypeText: (->
    trackableType = @get 'trackableType'

    if trackableType == 'event'
      'an event'
    else # comment, post
      "a #{trackableType}"
  ).property('trackableType')

  commentableType: (->
    if @get 'trackable.commentable'
      Yostalgia.Utilities.constructorToString @get('trackable.commentable.constructor')
  ).property('trackable.commentable')

  redirectType: (->
    return @get 'commentableType' if @get 'commentableType'
    @get 'trackableType'
  ).property('trackableType', 'commentableType')

  redirectModel: (->
    if @get 'commentableType'
      @get 'trackable.commentable'
    else
      @get 'trackable'
  ).property('trackableType', 'commentableType')

  bodyText: (->
    Yostalgia.Utilities.truncate(@get('trackable.body'), 50, plain: true)
  ).property('trackable.body')
