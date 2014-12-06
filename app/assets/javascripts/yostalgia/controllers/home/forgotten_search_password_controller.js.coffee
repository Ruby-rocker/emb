Yostalgia.HomeForgottenSearchPasswordController = Yostalgia.ObjectController.extend

  login: null
  isSaving: false
  isFinished: false

  actions:
    sendSearchResetLink: ->
      if @blank 'login'
        @send 'pushAlert', 'warn', 'Oops', 'Please enter your e-mail'
        return

      @set 'isSaving', true
      $.post('/private_public_searches/password', @get('paramsHash')).then(=>
        @set 'isFinished', true
        @set 'isSaving', false
      ).fail =>
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong. Please try again'
        @set 'isSaving', false


# bindings

  submitDisabled: (->
    return true if @get('isSaving')
    return true if @get('emailValidation.failed')
    false
  ).property(
    'isSaving',
    'emailValidation.failed')

# validate email

  emailValidation: (->
    return Yostalgia.InputValidation.create(failed: true) if @blank 'login'

    if !Yostalgia.Utilities.emailValid @get('login')
      return Yostalgia.InputValidation.create
        failed: true
        reason: 'Please enter a valid e-mail address.'
    else
      return Yostalgia.InputValidation.create
        ok: true
        reason: "Looks good. We'll e-mail you reset link."

    return Yostalgia.InputValidation.create
      failed: true
      reason: 'Checking email...'
  ).property('login')

  paramsHash: (->
    { private_public_search: { login: @get('login') } }
  ).property('login')
