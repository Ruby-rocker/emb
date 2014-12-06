Yostalgia.AccountSettingsController = Yostalgia.OverlayController.extend

  needs: ['application']

  oldEmail: null
  oldUsername: null

  uniqueEmailValidation: null
  uniqueUsernameValidation: null
  isSaving: false

  hasEmailNotifications: Ember.computed.any(
    'emailOnFriendRequest',
    'emailOnComment',
    'emailOnLike',
    'emailOnEventInvite',
    'emailOnEventPost',
    'emailOnMessage',
    'emailOnMention'
  )

  actions:
    save: ->
      return if @get 'submitDisabled'

      if !@get('isDirty')
        @send 'close'
        return

      @set 'isSaving', true
      @get('model').save().then =>
        @send 'pushAlert', 'success', 'Your details have been updated'
        @set 'isSaving', false
      , (error) =>
        @set 'isSaving', false
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong! Please try again'
        console.log error

    toggleFacebook: ->
      if @get('model.facebookConnected')
        # destroy authentication
        auth = @get('authentications').findBy('provider', 'facebook')
        auth.deleteRecord()
        auth.save().then =>
          @send 'pushAlert', 'warn', 'Your Facebook account has been unlinked'
      else
        # redirect to omniauth controller
        $.cookie 'oauth_auth_token', @auth.get('authToken'), { path: '/' }
        window.location = "/users/auth/facebook"

    toggleTwitter: ->
      if @get('model.twitterConnected')
        # destroy authentication
        auth = @get('authentications').findBy('provider', 'twitter')
        auth.deleteRecord()
        auth.save().then =>
          @send 'pushAlert', 'warn', 'Your Twitter account has been unlinked'
      else
        # redirect to omniauth controller
        $.cookie 'oauth_auth_token', @auth.get('authToken'), { path: '/' }
        window.location = "/users/auth/twitter"

    close: ->
      @get('model').then (user) ->
        user.rollback()
      @_super()


  facebookButtonText: (->
    if @get('model.facebookConnected') then 'Disconnect' else 'Connect'
  ).property('facebookConnected')

  twitterButtonText: (->
    if @get('model.twitterConnected') then 'Disconnect' else 'Connect'
  ).property('twitterConnected')

  submitDisabled: (->
    return true if @get 'isSaving'
    return true if @get 'emailValidation.failed'
    return true if @get 'usernameValidation.failed'
    return true if @get 'passwordValidation.failed'
    false
  ).property(
    'isSaving',
    'emailValidation.failed',
    'usernameValidation.failed',
    'passwordValidation.failed')

  submitText: (->
    if @get 'isSaving'
      'Saving...'
    else
      'Save changes'
  ).property('isSaving')

  doNotSendEmail: ((key, value) ->
    if arguments.length == 2 && value == true
      @set 'emailOnFriendRequest', false
      @set 'emailOnComment', false
      @set 'emailOnLike', false
      @set 'emailOnEventInvite', false
      @set 'emailOnEventPost', false
      @set 'emailOnMessage', false
      @set 'emailOnMention', false

    !@get('hasEmailNotifications')
  ).property(
    'emailOnFriendRequest',
    'emailOnComment',
    'emailOnLike',
    'emailOnEventInvite',
    'emailOnEventPost',
    'emailOnMessage',
    'emailOnMention')


  # validate email

  basicEmailValidation: (->
    if @get('email') != @get('oldEmail')
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
    if @get('email') != @get('oldEmail')
      Yostalgia.Signup.checkEmail(@get('email')).then (result) =>
        validation = Yostalgia.InputValidation.create
          failed: true
          reason: "Sorry, that e-mail is already taken"
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
    @set 'uniqueUsernameValidation', null
    unless @get('username') == @get('oldUsername')

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
    unless @get('username') == @get('oldUsername')
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

  # validate password

  passwordValidation: (->
    return if @blank 'password'

    if @get('password').length < 6
      return Yostalgia.InputValidation.create
        failed: true
        reason: 'Your password is too short.'

    return Yostalgia.InputValidation.create(ok: true)
  ).property('password')

## validate confirm password
#
#  passwordConfirmationValidation: (->
#    return if @blank 'confirm_password'
#
#    if @get('password') != @get('confirm_password')
#      return Yostalgia.InputValidation.create
#        failed: true
#        reason: 'Your password doesnt match with confirm password'
#
#    return Yostalgia.InputValidation.create(ok: true)
#  ).property('password', 'confirm_password')
