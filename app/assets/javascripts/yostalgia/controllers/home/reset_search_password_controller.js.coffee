Yostalgia.HomeResetSearchPasswordController = Yostalgia.ObjectController.extend

  queryParams: ['resetSearchPasswordToken:reset_password_token']

  resetSearchPasswordToken: null
  newPassword: ""

  passwordWithLoginPasswordValidation: null

  isSaving: false
  isFinished: false
  submitDisabled: Ember.computed.any 'isSaving', 'isFinished'

  actions:
    changePassword: ->
      if @blank 'newPassword'
        @send 'pushAlert', 'warn', 'Oops', 'Please enter your new password!'
        return

      @set 'isSaving', true
      $.ajax(url: '/private_public_searches/password.json', type: 'PUT', data: @get('paramsHash')).then(=>
        @set 'isFinished', true
        @set 'isSaving', false
      ).fail (xhr) =>
        @send 'pushAlert', 'alert', 'Uh-oh', "Something went wrong: \"#{xhr.responseText}\""
        @set 'isSaving', false

  paramsHash: (->
    private_public_search:
      reset_password_token: @get('resetSearchPasswordToken'),
      password: @get('newPassword'),
      password_confirmation: @get('newPassword')
  ).property('resetSearchPasswordToken', 'newPassword')

# validate password

  basicPasswordValidation: (->
    @set 'passwordWithLoginPasswordValidation', null
    if @get('newPassword').length < 6
      return Yostalgia.InputValidation.create
        failed: true
        reason: 'Your password is too short'

    @passwordCheckWithLoginPassword()
  ).property('newPassword')

  passwordCheckWithLoginPassword: Yostalgia.debounce(->
    Yostalgia.SearchResult.validateWithUserPassword(@get('newPassword'), @session.get('user.id')).then (result) =>
      if !result
        validation = Yostalgia.InputValidation.create(ok: true)
      else
        if result.errors
          validation = Yostalgia.InputValidation.create
            failed: true
            reason: result.errors.join(' ')
        else
          validation = Yostalgia.InputValidation.create
            failed: true
            reason: 'Your password cannot be the same as your login password'
      @set('passwordWithLoginPasswordValidation', validation)

    return Yostalgia.InputValidation.create(ok: true)
  , 500)

  passwordValidation: (->
    basicPasswordValidation   = @get('basicPasswordValidation')
    passwordWithLoginPasswordValidation  = @get('passwordWithLoginPasswordValidation')
    return passwordWithLoginPasswordValidation if passwordWithLoginPasswordValidation
    basicPasswordValidation
  ).property('basicPasswordValidation', 'passwordWithLoginPasswordValidation')

# bindings

  submitDisabled: (->
    return true if @get('passwordValidation.failed')
    false
  ).property(
    'passwordValidation.failed')