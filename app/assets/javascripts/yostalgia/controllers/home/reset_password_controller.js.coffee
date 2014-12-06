Yostalgia.HomeResetPasswordController = Yostalgia.ObjectController.extend

  queryParams: ['resetPasswordToken:reset_password_token']

  resetPasswordToken: null
  newPassword: null

  isSaving: false
  isFinished: false
  submitDisabled: Ember.computed.any 'isSaving', 'isFinished'

  actions:
    changePassword: ->
      if @blank 'newPassword'
        @send 'pushAlert', 'warn', 'Oops', 'Please enter your new password!'
        return

      @set 'isSaving', true
      $.ajax(url: '/users/password.json', type: 'PUT', data: @get('paramsHash')).then(=>
        @set 'isFinished', true
        @set 'isSaving', false
      ).fail (xhr) =>
        @send 'pushAlert', 'alert', 'Uh-oh', "Something went wrong: \"#{xhr.responseText}\""
        @set 'isSaving', false

  paramsHash: (->
    user:
      reset_password_token: @get('resetPasswordToken'),
      password: @get('newPassword'),
      password_confirmation: @get('newPassword')
  ).property('resetPasswordToken', 'newPassword')
