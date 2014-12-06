Yostalgia.MessagesNewController = Yostalgia.ObjectController.extend

  queryParams: ['recipientIds']
  recipientIds: null

  userSearchResults: Ember.A()

  actions:
    searchUsers: (term) ->
      unless Ember.isEmpty term
        @store.find('user', search: term, friends: true).then (users) =>
          @set 'userSearchResults', users

    save: ->
      if Ember.isEmpty @get('body')
        @send 'pushAlert', 'warn', 'No text', 'Enter some text to send a message'
        return

      if Ember.isEmpty @get('recipients')
        @send 'pushAlert', 'warn', 'No recipeints', 'Who are you sending a message to?'
        return

      @get('model').save().then (message) =>
        @transitionToRoute 'conversation', message.get('conversation')
      , (error) =>
        @send 'pushAlert', 'alert', 'Uh-oh!', 'Something went wrong. Please try again'


  recipientIdsChanged: (->
    unless Ember.isEmpty @get('recipientIds')
      @get('store').find('user', @get('recipientIds')).then (users) =>
        users = Ember.A().concat users
        @get('recipients').pushObjects users
  ).observes('recipientIds').on('init')
