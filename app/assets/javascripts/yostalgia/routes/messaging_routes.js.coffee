Yostalgia.MessagesRoute = Yostalgia.SecretRoute.extend
  model: ->
    @controllerFor('messages').send 'loadNew'
    @store.filter 'conversation'

  afterModel: ->
    @_super.apply(this, arguments)
    @controllerFor('messages').send 'startPollingForNew'

  deactivate: ->
    @_super.apply(this, arguments)
    @controllerFor('messages').send 'stopPollingForNew'
    @controllerFor('messages').send 'stopInactivityTimer'

  setupController: (controller, model) ->
    @_super controller, model
    @controllerFor('application').set 'currentRoute', 'messages'

Yostalgia.MessagesNewRoute = Yostalgia.SecretRoute.extend
  model: (params) ->
    if params.recipientIds
      @store.find('conversation', recipient_ids: params.recipientIds).then (conversations) =>
        if Ember.isEmpty conversations
          message = @store.createRecord 'message'
          message.set 'user', @session.get('user.content')
          return message
        else
          @transitionTo 'conversation', conversations.get('firstObject')
    else
      message = @store.createRecord 'message'
      message.set 'user', @session.get('user.content')
      return message

Yostalgia.MessagesSearchRoute = Yostalgia.SecretRoute.extend()

Yostalgia.ConversationRoute = Yostalgia.SecretRoute.extend
  actions:
    markConversationAsRead: ->
      conversation = @modelFor('conversation')
      conversation.markAsRead().then =>
        @send 'refreshNotificationCounts'
        @store.filter('message', (message) ->
          message.get('conversation.id') == conversation.get('id')
        ).then (messages) ->
          messages.forEach (message) ->
            message.set 'unread', false
  model: (params) ->
    @store.find('conversation', params['conversation_id'])
  afterModel: (model, transition) ->
    transition.send 'markConversationAsRead'

Yostalgia.ConversationIndexRoute = Yostalgia.SecretRoute.extend
  model: ->
    @store.filter 'message', (message) =>
      message.get('conversation.id') == @modelFor('conversation').get('id')

  afterModel: ->
    @_super.apply(this, arguments)
    controller = @controllerFor('conversation.index')
    checkNewTimer = controller.get('checkNewTimer')
    clearInterval checkNewTimer if checkNewTimer
    checkNewTimer = setInterval =>
      controller.send 'loadNew'
    , controller.get('loadNewPeriod')
    controller.set 'checkNewTimer', checkNewTimer

  deactivate: ->
    @_super.apply(this, arguments)
    controller = @controllerFor('conversation.index')
    checkNewTimer = controller.get('checkNewTimer')
    clearInterval checkNewTimer
    controller.set 'checkNewTimer', null

  setupController: (controller, model) ->
    @_super controller, model
    controller.send 'loadNew'
