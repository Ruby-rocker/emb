Yostalgia.SignupRoute = Yostalgia.MarketingRoute.extend
  renderTemplate: ->
    @render 'home'

Yostalgia.SignupIndexRoute = Yostalgia.MarketingRoute.extend
  redirect: ->
    @replaceWith 'signup.step_1'

Yostalgia.SignupStep1Route = Yostalgia.MarketingRoute.extend
  redirect: ->
    if @session.get('isAuthenticated')
      @replaceWith 'newsfeed'
  setupController: (controller, model) ->
    @_super(controller, model)
    controller.send 'setupSignup'

Yostalgia.SignupStep2Route = Yostalgia.SecretMarketingRoute.extend
  model: ->
    @session.get('user').then (user) =>
      user.get('profile').then (profile) ->
        if !profile.get('photo')
          profile.set 'photo', @get('store').createRecord('attachment')
        return profile

Yostalgia.SignupStep3Route = Yostalgia.SecretMarketingRoute.extend
  setupController: (controller, model) ->
    @_super(controller, model)
    controller.send 'setupStep3'

Yostalgia.SignupConfirmationRoute = Yostalgia.MarketingRoute.extend()

Yostalgia.SignupTwitterRoute = Yostalgia.MarketingRoute.extend
  queryParams:
    auth:
      refreshModel: true
  model: (params) ->
    auth = params.auth
    params.auth = undefined
    if auth
      @controllerFor('signup.twitter').set 'oauth', JSON.parse(auth)
  setupController: (controller, model) ->
    controller.send 'setupSignup'
