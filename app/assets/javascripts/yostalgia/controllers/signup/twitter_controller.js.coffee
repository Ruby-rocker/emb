Yostalgia.SignupTwitterController = Yostalgia.ObjectController.extend

  queryParams: ['auth']
  auth: null
  oauth: null

  uniqueEmailValidation: null
  uniqueUsernameValidation: null

  validationsDisabled: false

  # actions

  actions:
    setupSignup: ->
      if @get 'oauth'
        @set 'model', @get('store').createRecord('signup') if @blank 'model'

        oauth = @get 'oauth'
        console.log oauth
        signup = @get 'model'
        signup.set 'username', oauth.info.nickname
        signup.set 'fullName', oauth.info.name

        signup.set 'location', oauth.info.location
        signup.set 'aboutMe', oauth.info.description
        signup.set 'imageUrl', oauth.info.image.replace('_normal', '')

        signup.set 'oauthProvider', oauth.provider
        signup.set 'oauthUid', oauth.uid
        signup.set 'oauthToken', oauth.credentials.token
        signup.set 'oauthSecret', oauth.credentials.secret

      else
        @transitionToRoute 'signup'

    cancel: ->
      @transitionToRoute 'home'

    completeSignup: ->
      @set 'validationsDisabled', true
      @get('model').save().then (signup) =>
        window.location = "/signup/step_2?auth_token=#{signup.get('authToken')}"
      , (error) =>
        @send 'pushAlert', 'alert', 'Sorry', 'Something went wrong! Please try again'
        @set 'validationsDisabled', false
        console.log error


  # bindings

  submitDisabled: (->
    return true if @get('isSaving')
    return true if @get('emailValidation.failed')
    return true if @get('usernameValidation.failed')
    return true if @get('fullnameValidation.failed')
    false
  ).property(
    'isSaving',
    'emailValidation.failed',
    'usernameValidation.failed',
    'fullnameValidation.failed')

  # validate email

  basicEmailValidation: (->
    unless @get 'validationsDisabled'
      @set 'uniqueEmailValidation', null
      return Yostalgia.InputValidation.create(failed: true) if @blank 'email'

      if !Yostalgia.Utilities.emailValid @get('email')
        return Yostalgia.InputValidation.create
          failed: true
          reason: 'Please enter a valid e-mail address.'

      @checkEmailAvailability()
      return Yostalgia.InputValidation.create
        failed: true
        reason: 'Checking email...'
  ).property('email')

  checkEmailAvailability: Yostalgia.debounce(->
    Yostalgia.Signup.checkEmail(@get('email')).then (result) =>
      if result.available
        validation = Yostalgia.InputValidation.create
          ok: true
          reason: "Looks good. We'll e-mail you to confirm."
      else
        validation = Yostalgia.InputValidation.create
          failed: true
          reason: "Sorry, that e-mail is already taken.
            <a href=\"/sign_in\">Sign in?</a>"
      @set('uniqueEmailValidation', validation)
  , 500)

  emailValidation: (->
    basicEmailValidation   = @get('basicEmailValidation')
    uniqueEmailValidation  = @get('uniqueEmailValidation')
    return uniqueEmailValidation if uniqueEmailValidation
    basicEmailValidation
  ).property('basicEmailValidation', 'uniqueEmailValidation')

  # validate username

  basicUsernameValidation: (->
    unless @get 'validationsDisabled'
      @set 'uniqueUsernameValidation', null

      if @blank 'username'
        return Yostalgia.InputValidation.create(failed: true)

      if @get('username').length < 3
        return Yostalgia.InputValidation.create
          failed: true
          reason: 'must be longer than 3 characters'

      if @get('username').length > 20
        return Yostalgia.InputValidation.create
          failed: true
          reason: 'must be shorter than 20 characters'

      @checkUsernameAvailability()

      return Yostalgia.InputValidation.create
        failed: true,
        reason: 'checking username...'
  ).property('username')

  checkUsernameAvailability: Yostalgia.debounce(->
    Yostalgia.Signup.checkUsername(@get('username')).then (result) =>
      if result.available
        validation = Yostalgia.InputValidation.create(ok: true)
      else
        if result.errors
          validation = Yostalgia.InputValidation.create
            failed: true
            reason: result.errors.join(' ')
        else
          validation = Yostalgia.InputValidation.create
            failed: true
            reason: 'Already registered.'
      @set('uniqueUsernameValidation', validation)
  , 500)

  usernameValidation: (->
    basicUsernameValidation   = @get('basicUsernameValidation')
    uniqueUsernameValidation  = @get('uniqueUsernameValidation')
    return uniqueUsernameValidation if uniqueUsernameValidation
    basicUsernameValidation
  ).property('basicUsernameValidation', 'uniqueUsernameValidation')

  # validate full name

  fullnameValidation: (->
    unless @get 'validationsDisabled'
      if @blank 'fullName'
        return Yostalgia.InputValidation.create(failed: true)

      if @blank('firstName') or @blank('lastName')
        return Yostalgia.InputValidation.create
          failed: true
          reason: 'Please provide both your first and last name.'

      return Yostalgia.InputValidation.create(ok: true)
  ).property('fullName')
