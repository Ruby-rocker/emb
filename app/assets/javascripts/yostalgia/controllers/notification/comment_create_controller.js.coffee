Yostalgia.NotificationCommentCreateController = Yostalgia.NotificationBaseController.extend

  comment: Ember.computed.alias('trackable')
  commentable: Ember.computed.alias('trackable.commentable')

  actions:
    transitionToItem: ->
      switch @get('commentable.constructor')
        when Yostalgia.Post
          @transitionToRoute 'post', @get('commentable')
        when Yostalgia.Attachment
          if @get('commentable.isProfileAttachment')
            @transitionToRoute 'profile_photos.photo', @get('commentable.user'), @get('commentable.id')
          else if @get('commentable.isCoverPhotoAttachment')
            @transitionToRoute 'cover_photos.photo', @get('commentable.user'), @get('commentable.id')
          else
            @transitionToRoute 'post.attachment', @get('commentable.attachable'), @get('commentable')

  isOwnCommentable: (->
    if @get 'commentable.user'
      @get('commentable.user').then (user) =>
        user.get('id') == @session.get('user.id')
  ).property('commentable', 'commentable.user.id', 'session.user.id')

  isInstigatorsCommentable: (->
    if @get 'commentable.user'
      @get('commentable.user').then (user) =>
        @get('owner').then (owner) ->
          user == owner
  ).property('owner', 'commentable.user')

  actionText: (->
    currentUser = @session.get('user.content')
    commentUsers = @get('commentable.comments.@each.user')

    if commentUsers.contains(currentUser)
      'also commented on'
    else
      'commented on'
  ).property('commentable.comments.@each.user', 'session.user.content')

  posessionText: (->
    if @get('isOwnCommentable')
      return 'your'
    if @get('isInstigatorsTrackable')
      return if @get('owner.profile.isMale') then 'his' else 'her'
    null
  ).property('commentable.user', 'owner')

  showCommentableOwnersName: (->
    !@get('isOwnCommentable') && !@get('isInstigatorsTrackable')
  ).property('isOwnCommentable')

  commentableType: (->
    commentable = @get('commentable')
    commentable_type = Yostalgia.Utilities.constructorToString(@get('commentable.constructor'))

    if commentable_type == 'attachment'
      "#{if commentable.get('isProfileAttachment') then 'profile' else ''} photo"
    else
      commentable_type
  ).property('commentable')

  commentText: (->
    Yostalgia.Utilities.truncate(@get('trackable.body'), 50, plain: true)
  ).property('trackable.body')
