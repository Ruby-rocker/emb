Yostalgia.HomeResendConfirmationController = Yostalgia.ObjectController.extend

  login: null
  isSaving: false
  submitDisabled: Ember.computed.any 'isSaving', 'isFinished'
  isFinished: false

  actions:
    resendConfirmation: ->
      if @blank 'login'
        @send 'pushAlert', 'warn', 'Oops', 'Please enter your e-mail or username'
        return

      @set 'isSaving', true
      $.post('/users/confirmation', @get('paramsHash')).then(=>
        @set 'isFinished', true
        @set 'isSaving', false
      ).fail (xhr) =>
        @send 'pushAlert', 'alert', 'Uh-oh', "Something went wrong: \"#{xhr.responseText}\""
        @set 'isSaving', false

  paramsHash: (->
    user:
      login: @get('login')
  ).property('login')
