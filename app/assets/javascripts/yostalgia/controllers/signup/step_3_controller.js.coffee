Yostalgia.SignupStep3Controller = Yostalgia.ObjectController.extend

  users: null
  selected_friends: Ember.A()

  actions:
    setupStep3: ->
      @set 'users', []
      @get('store').find('user', socialMatches: true).then (users) =>
        @set 'users', users

    toggleFriendFinder: (friend) ->
      if @get('selected_friends').contains(friend)
        @get('selected_friends').popObject friend
      else
        @get('selected_friends').pushObject friend

      friend.set 'isSelected', !friend.get('isSelected')

    connectFacebook: ->
      if @get('facebookConnected')
        # destroy authentication
        auth = @get('authentications').findBy('provider', 'facebook')
        auth.deleteRecord()
        auth.save().then =>
          @send 'pushAlert', 'warn', 'Your Facebook account has been unlinked'
      else
        # redirect to omniauth controller
        $.cookie 'oauth_auth_token', @auth.get('authToken'), { path: '/' }
        window.location = "/users/auth/facebook"

    connectTwitter: ->
      if @get('twitterConnected')
        # destroy authentication
        auth = @get('authentications').findBy('provider', 'twitter')
        auth.deleteRecord()
        auth.save().then =>
          @send 'pushAlert', 'warn', 'Your Twitter account has been unlinked'
      else
        # redirect to omniauth controller
        $.cookie 'oauth_auth_token', @auth.get('authToken'), { path: '/' }
        window.location = "/users/auth/twitter"

    completeStep: ->
      @get('selected_friends').forEach (receiverUser) =>
        friendship =
          pending: true
          sender: @session.get 'user.content'
          receiver: receiverUser

        friendship = @get('store').createRecord('friendship', friendship)
        friendship.save().then =>
          @send 'pushAlert', 'success', 'All Friend request sent'
        , (error) =>
          friendship.rollback()
          @send 'pushAlert', 'alert', 'Uh-oh', "Something went wrong :("
          console.log error

      @transitionToRoute 'newsfeed'

  facebookButtonText: (->
    if @get('facebookConnected') then 'Disconnect' else 'Connect'
  ).property('facebookConnected')

  twitterButtonText: (->
    if @get('twitterConnected') then 'Disconnect' else 'Connect'
  ).property('twitterConnected')

  loadUser: (->
    if @session.get 'user.content'
      @set 'model', @session.get('user.content')
  ).observes('session.user.content').on('init')
