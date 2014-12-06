Yostalgia.Signup = Yostalgia.Model.extend

  username:     DS.attr('string')
  email:        DS.attr('string')
  password:     DS.attr('string')
  firstName:    DS.attr('string')
  lastName:     DS.attr('string')

  location:     DS.attr('string')
  aboutMe:      DS.attr('string')
  imageUrl:     DS.attr('string')

  oauthProvider:  DS.attr('string')
  oauthUid:       DS.attr('string')
  oauthToken:     DS.attr('string')
  oauthSecret:    DS.attr('string')

  authToken: DS.attr('string')

  fullName: ((key, value)->
    if arguments.length == 2 and value
      name = value.split(' ')
      @set 'firstName', name[0]
      @set 'lastName', name.slice(1).join(' ')

    if @get('firstName') or @get('lastName')
      $.trim("#{@get('firstName')} #{@get('lastName')}")
    else
      null
  ).property('firstName', 'lastName')

Yostalgia.Signup.reopenClass

  checkEmail: (email) ->
    $.ajax
      url: '/api/v1/signups/check_email'
      type: 'GET'
      data: { email: email }

  checkUsername: (username) ->
    $.ajax
      url: '/api/v1/signups/check_username'
      type: 'GET'
      data: { username: username }
