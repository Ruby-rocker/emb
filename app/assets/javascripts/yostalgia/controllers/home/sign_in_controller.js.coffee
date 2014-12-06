Yostalgia.HomeSignInController = Ember.Controller.extend Ember.SimpleAuth.LoginControllerMixin,

  authenticatorFactory: 'authenticator:yostalgia'

  remember: true

  isLoading: false
  validationFailed: false
  errorMessage: null

  loginValidation: null
  passwordValidation: null

  submitDisabled: (->
    return true if @get 'isLoading'
    return false
  ).property('isLoading')

  updateLoginValidation: (->
    if @get('loginValidation.failed') and !Ember.isEmpty(@get 'identification')
      @set 'loginValidation', null
  ).observes('identification')

  updatePasswordValidation: (->
    if @get('passwordValidation.failed') and !Ember.isEmpty(@get 'password')
      @set 'passwordValidation', null
  ).observes('password')


  ### actions ###

  actions:
    authenticate: ->
      @validate()
      return if @get('validationFailed')

      @set 'isLoading', true
      @_super.apply(this, arguments)


  ### methods ###

  validateLogin: ->
    if Ember.isEmpty @get('identification')
      @set 'validationFailed', true
      @set 'loginValidation', Yostalgia.InputValidation.create
        failed: true
        reason: 'Please provide your email or username'
    else
      @set 'loginValidation', Yostalgia.InputValidation.create(ok: true)

  validatePassword: ->
    if Ember.isEmpty @get('password')
      @set 'validationFailed', true
      @set 'passwordValidation', Yostalgia.InputValidation.create
        failed: true
        reason: 'Please provide your password'
    else
      @set 'passwordValidation', Yostalgia.InputValidation.create(ok: true)

  validate: ->
    @set 'validationFailed', false
    @validateLogin()
    @validatePassword()


