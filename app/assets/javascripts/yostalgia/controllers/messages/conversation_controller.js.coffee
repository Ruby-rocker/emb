Yostalgia.ConversationController = Yostalgia.ObjectController.extend Ember.Evented,

  needs: ['conversationIndex']

  newMessageBody: null

  actions:
    sendMessage: ->
      unless @blank 'newMessageBody'
        message = @store.createRecord 'message'
        message.set 'conversation', @get('model')
        message.set 'body', @get('newMessageBody')
        message.save().then (message) =>
          @set 'newMessageBody', null
          @trigger 'resetNewMessage'
        , (error) =>
          @send 'pushAlert', 'alert', 'Uh-oh!', 'Something went wrong. Please try again'
          console.log error
