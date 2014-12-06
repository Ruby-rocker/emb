Yostalgia.EventRoute = Yostalgia.SecretRoute.extend
  actions:
    createEventPost: (event) ->
      @controllerFor('event.post.form.overlay').create(event)
      @send 'openOverlay', 'event.post.form.overlay'

Yostalgia.EventIndexRoute = Yostalgia.SecretRoute.extend
  model: ->
    @modelFor 'event'

Yostalgia.EventInviteesRoute = Yostalgia.SecretRoute.extend
  model: ->
    @modelFor 'event'

Yostalgia.EventPostsRoute = Yostalgia.SecretRoute.extend
  activate: ->
    @controllerFor('application').set 'onEventFeed', true
    @_super.apply(this, arguments)
  model: ->
    currentEvent = @modelFor('event')
    currentEvent.get('posts')
    @store.filter 'post', (post) ->
      post.get('event') == currentEvent && post.get('isPrivate') == false

  afterModel: ->
    @controllerFor('application').set 'previousRouteForPost', 'event.posts'
    @controllerFor('application').set 'previousEventForPost', @modelFor('event')
    @_super.apply(this, arguments)
  deactivate: ->
    @controllerFor('application').set 'onEventFeed', false
    @_super.apply(this, arguments)
