Yostalgia.Router.reopen
  location: 'history'

Yostalgia.Router.map ->
  @resource 'home', ->
    @route 'sign_in'
    @route 'confirmation_required'
    @route 'forgotten_password'
    @route 'reset_password'
    @route 'resend_confirmation'
    @route 'forgotten_search_password'
    @route 'reset_search_password'
  @resource 'signup', ->
    @route 'step_1'
    @route 'step_2'
    @route 'step_3'
    @route 'confirmation'
    @route 'twitter'
  @resource 'newsfeed', ->
  @resource 'post', { path: '/post/:post_id' }, ->
    @route 'attachment', { path: '/:attachment_id' }
  @resource 'event', { path: '/event/:event_id'}, ->
    @route 'posts'
    @route 'invitees'
  @resource 'user', { path: '/user/:user_id' }, ->
    @route 'profile_version', { path: '/flashback/:date' }
    @resource 'user_feed', { path: '/feed' }, ->
      @route 'posts', { path: '/:date' }
    @route 'event_calendar', { path: '/events/:date'}
    @route 'friends'
    @route 'photos'
    @resource 'profile_photos', ->
      @route 'photo', { path: '/:photo_id' }
    @resource 'cover_photos', ->
      @route 'photo', { path: '/:photo_id' }
    @route 'events'
  @resource 'messages', ->
    @route 'new'
    @route 'search', { path: '/search/:term' }
    @resource 'conversation', { path: '/:conversation_id' }, ->
  @route 'search'
  @route 'sign_out'
  @resource 'account', ->
    @route 'email'
    @route 'password'
    @route 'privacy'
  @route 'component_test'
  @route 'missing', { path: '/*path' }

Yostalgia.Route = Ember.Route.extend
  afterModel: ->
    if @controllerFor('application').get 'overlayOpen'
      @send 'closeOverlay'
    @_super()
  actions:
    openOverlay: (overlay) ->
      @controllerFor('application').set 'overlayOpen', true
      @render overlay, { into: 'application', outlet: 'overlay' }
    closeOverlay: ->
      @controllerFor('application').set 'overlayOpen', false
      @render 'empty', { into: 'application', outlet: 'overlay' }

Yostalgia.SecretRoute = Yostalgia.Route.extend(
  Ember.SimpleAuth.AuthenticatedRouteMixin
)

Yostalgia.ApplicationRoute = Yostalgia.Route.extend Ember.SimpleAuth.ApplicationRouteMixin,
  actions:
    error: (reason) ->
      if reason.status == 404
        @transitionTo('missing')
      return true
    sessionAuthenticationSucceeded: ->
      # TODO: add auth details to Raven
      attemptedTransition = @get 'session.attemptedTransition'
      blacklistRoutes = [
        'home',
        'home.sign_in'
        'home.confirmation_required'
        'home.forgotten_password'
        'home.reset_password'
        'home.resend_confirmation'
        'home.reset_search_password'
      ]
      if attemptedTransition
        if blacklistRoutes.indexOf(attemptedTransition.targetName) > -1
          @transitionTo 'newsfeed.index'
        else
          @_super()
      else
        @_super()
    sessionAuthenticationFailed: (error) ->
      loginController = @controllerFor 'home.sign_in'
      loginController.set 'isLoading', false
      if error.message == 'confirmation required'
        @transitionTo 'home.confirmation_required'
      else
        loginController.set 'errorMessage', error.message
    openModal: (modal, controller = null) ->
      options =
        into: 'application'
        outlet: 'modal'
      options['controller'] = controller if controller
      @render modal, options
    closeModal: ->
      @disconnectOutlet outlet: 'modal', parentView: 'application'
    openFriendSelectorModal: (availableFriends, actionController, actionText) ->
      controller = @controllerFor('friendSelectorModal')
      if availableFriends.then?
        controller.set 'isLoading', true
        availableFriends.then (friends) ->
          controller.set 'isLoading', false
          controller.set 'model', friends
      else
        controller.set 'isLoading', false
        controller.set 'model', availableFriends
      controller.set 'actionText', actionText
      controller.set 'actionController', actionController
      @send 'openModal', 'friendSelectorModal'
    openAllEmotionsModal: (likeable) ->
      controller = @controllerFor('allEmotionsModal')
      controller.set 'model', likeable
      controller.set 'selectedEmotion', Yostalgia.Like.LOVE
      likeable.get('likes')
      @send 'openModal', 'allEmotionsModal', controller
    createPost: ->
      @controllerFor('post.form.overlay').create()
      @send 'openOverlay', 'post.form.overlay'
    createEvent: ->
      @controllerFor('event.form.overlay').create()
      @send 'openOverlay', 'event.form.overlay'
    showTextPostOverlay: (post) ->
      @controllerFor('post.text.overlay').show(post)
      @send 'openOverlay', 'post.text.overlay'
    showNotifications: ->
      if $('#notifications_overlay').is(':visible')
        @send 'closeOverlay'
      else
        @controllerFor('notifications').send 'loadNotifications'
        @send 'openOverlay', 'notifications'
    showSettings: ->
      if $('#settings_overlay').is(':visible')
        @send 'closeOverlay'
      else
        settingsController = @controllerFor('account.settings')
        settingsController.set 'oldEmail', @session.get('user.email')
        settingsController.set 'oldUsername', @session.get('user.username')
        settingsController.set 'model', @session.get('user')
        @send 'openOverlay', 'account.settings'
    reloadNewsfeed: ->
      @controllerFor('newsfeed').send('loadFirstPage')
    pushAlert: (type, title, message) ->
      alertMessage = Ember.Object.create
        type: type
        title: title
        message: message
        closed: false
      @controller.get('alertMessages').pushObject alertMessage
    refreshNotificationCounts: ->
      @controllerFor('application').refreshNotificationCounts()

Yostalgia.IndexRoute = Yostalgia.Route.extend
  redirect: ->
    if @session.isAuthenticated
      @replaceWith 'newsfeed'
    else
      @replaceWith 'home'

Yostalgia.NewsfeedRoute = Yostalgia.SecretRoute.extend
  setupController: (controller, model) ->
    @_super controller, model
    controller.send 'loadFirstPage'
    @controllerFor('application').set 'currentRoute', 'newsfeed'
    @controllerFor('application').set 'previousRouteForPost', 'newsfeed'
    @controllerFor('memoryLane').set 'forUser', null
    @controllerFor('memoryLane').send 'refresh'
  renderTemplate: ->
    @render()
    @render 'memoryLane',
      into: 'newsfeed',
      outlet: 'memoryLane',
      controller: 'memoryLane'


Yostalgia.SearchRoute = Yostalgia.SecretRoute.extend
  setupController: (controller, model) ->
    @_super(controller, model)
    @controllerFor('application').set('isSearch', true)
  deactivate: ->
    @controllerFor('application').set('isSearch', false)


Yostalgia.AccountRoute = Yostalgia.SecretRoute.extend
  model: ->
    @session.get('user')
  setupController: (controller, model) ->
    @_super(controller, model)
    @controllerFor('application').set('currentRoute', 'account')

Yostalgia.AccountSettingsRoute = Yostalgia.AccountRoute.extend()

Yostalgia.AccountPrivacyRoute = Yostalgia.AccountRoute.extend()

Yostalgia.PostIndexRoute = Yostalgia.SecretRoute.extend
  model: (params, transition) ->
    appController = @controllerFor 'application'
    post = @modelFor 'post'
    post.get('attachments').then (attachments) =>
      if !post.get('hasMedia') && !post.get('isEventPost')
        transition.abort()
        if !appController.get('currentRouteName')
          @transitionTo('newsfeed.index').then =>
            @send 'showTextPostOverlay', post
        else
          @send 'showTextPostOverlay', post
    post
  setupController: (controller, model) ->
    @_super controller, model
    controller.set 'comments', null
    controller.set 'comments', @store.filter 'comment', (comment) ->
      comment.get('commentable.constructor') == Yostalgia.Post &&
      comment.get('commentable.id') == model.get('id')
    controller.set 'commentsLoading', true
    @store.find('comment', post_id: model.get('id')).then =>
      controller.set 'commentsLoading', false

Yostalgia.AttachmentWithCommentsRoute = Yostalgia.SecretRoute.extend
  setupController: (controller, model) ->
    @_super controller, model
    controller.set 'comments', null
    controller.set 'comments', @store.filter 'comment', (comment) ->
      comment.get('commentable.constructor') == Yostalgia.Attachment &&
      comment.get('commentable.id') == model.get('id')
    controller.set 'commentsLoading', true
    @store.find('comment', attachment_id: model.get('id')).then =>
      controller.set 'commentsLoading', false

Yostalgia.PostAttachmentRoute = Yostalgia.AttachmentWithCommentsRoute.extend()

Yostalgia.MissingRoute = Yostalgia.Route.extend
  redirect: (params) ->
    if RAILS_ENV != 'development'
      Raven.captureMessage "404 error: /#{params.path}"
    @transitionTo 'index'
