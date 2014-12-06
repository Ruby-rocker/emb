YostalgiaAuthenticator = Ember.SimpleAuth.Authenticators.Devise.extend
  invalidate: ->
    Ember.$.ajax
      url: '/users/sign_out'
      type: 'DELETE'

LocalStorageWithURLAuth = Ember.SimpleAuth.Stores.LocalStorage.extend
  init: ->
    if $.QueryString['auth_token']
      auth_token = $.QueryString['auth_token']
      Ember.$.ajax(
        async: false
        url: '/users/sign_in'
        type: 'POST'
        data: { user_token: auth_token }
        dataType: 'json'
      ).then (data) =>
        @persist
          auth_token: data.user_token
          auth_email: data.user_email
          user_id: data.user_id
          authenticatorFactory: 'authenticator:yostalgia'
        @_super()
      , (error) =>
        @_super()
    else
      @_super()

Ember.Application.initializer
  name: 'authentication'
  initialize: (container, application) ->
    Ember.SimpleAuth.Session.reopen
      user: (->
        userId = @get 'user_id'
        if !Ember.isEmpty userId
          container.lookup('store:main').find 'user', userId
      ).property('user_id')

    container.register 'session-store:local-storage-url', LocalStorageWithURLAuth
    container.register 'authenticator:yostalgia', YostalgiaAuthenticator

    Ember.SimpleAuth.setup container, application,
      storeFactory: 'session-store:local-storage-url'
      authenticatorFactory: 'authenticator:yostalgia'
      authorizerFactory: 'ember-simple-auth-authorizer:devise'

      authenticationRoute: 'home.sign_in'

      routeAfterAuthentication: 'newsfeed'
