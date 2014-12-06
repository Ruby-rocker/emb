Yostalgia.HomeForgottenPasswordController = Yostalgia.ObjectController.extend

  login: null
  isSaving: false
  submitDisabled: Ember.computed.any 'isSaving', 'isFinished'
  isFinished: false

  actions:
    sendResetLink: ->
      if @blank 'login'
        @send 'pushAlert', 'warn', 'Oops', 'Please enter your e-mail or username'
        return

      @set 'isSaving', true
      $.post('/users/password', @get('paramsHash')).then(=>
        @set 'isFinished', true
        @set 'isSaving', false
      ).fail =>
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong. Please try again'
        @set 'isSaving', false

  paramsHash: (->
    { user: { login: @get('login') } }
  ).property('login')