Yostalgia.PostAttachmentController = Yostalgia.ObjectController.extend

  needs: ['application', 'post']

  comments: null
  commentsLoading: false

  actions:
    close: ->
      prev_route = @get('controllers.application.previousRouteForPost')
      prev_user = @get('controllers.application.previousUserForPost')
      if prev_route == 'user.photos' and prev_user
        @transitionToRoute 'user.photos', prev_user
      else
        @transitionToRoute 'post', @get('controllers.post.content')
