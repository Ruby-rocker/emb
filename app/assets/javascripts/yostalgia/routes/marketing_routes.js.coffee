Yostalgia.MarketingRoute = Yostalgia.Route.extend
  setupController: (controller, model) ->
    @_super(controller, model)
    @controllerFor('application').set('isMarketing', true)
  deactivate: ->
    @controllerFor('application').set('isMarketing', false)

Yostalgia.SecretMarketingRoute = Yostalgia.MarketingRoute.extend(
  Ember.SimpleAuth.AuthenticatedRouteMixin
)

Yostalgia.HomeRoute = Yostalgia.MarketingRoute.extend
  actions:
    terms: ->
      alert "TODO: Implement Ts & Cs page"
    privacy: ->
      alert "TODO: Implement privacy page"

Yostalgia.HomeIndexRoute = Yostalgia.MarketingRoute.extend()

Yostalgia.HomeSignInRoute = Yostalgia.MarketingRoute.extend
  redirect: ->
    if @get('session.isAuthenticated')
      @transitionTo 'newsfeed'


Yostalgia.HomeForgottenPasswordRoute = Yostalgia.MarketingRoute.extend()

Yostalgia.HomeResetPasswordRoute = Yostalgia.MarketingRoute.extend()

Yostalgia.HomeForgottenSearchPasswordRoute = Yostalgia.MarketingRoute.extend()

Yostalgia.HomeResetPasswordRoute = Yostalgia.MarketingRoute.extend
  setupController: (controller, model, queryParams) ->
    @_super(controller, model)
    controller.set 'resetPasswordToken', queryParams.reset_password_token

Yostalgia.HomeResetSearchPasswordRoute = Yostalgia.MarketingRoute.extend
  setupController: (controller, model, queryParams) ->
    @_super(controller, model)
    controller.set 'resetSearchPasswordToken', queryParams.reset_password_token

Yostalgia.HomeResendConfirmationRoute = Yostalgia.MarketingRoute.extend()
