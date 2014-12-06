Yostalgia.SearchController = Yostalgia.ObjectController.extend

  needs: ['application']

  query: Ember.computed.alias 'controllers.application.search'

  isLoading: false
  checkChecked: false
  checkPrivate: false

  isAllPosts: false
  isAllEvents: false
  isAllMedias:false
  isExistInSearch: false
  count: 1

  passwordWithLoginPasswordValidation: null
  password: ""
  confirm_password: ""

  actions:
    checkPassword: ->
      Yostalgia.SearchResult.checkPassword(@get('password'), @session.get('user.id')).then (result) =>
        @set 'checkPrivate', result
        @set 'checkChecked', result
        @performSearch()
        $('.modal-transparent').remove()
        unless result
          @send 'pushAlert', 'alert', 'Uh-oh', "You have entered wrong password :("

    createSearchPassword: ->
      Yostalgia.SearchResult.createSearchPassword(@get('password'), @session.get('user.id')).then (result) =>
        @set 'checkPrivate', result
        @set 'checkChecked', result
        @performSearch()
        $('.modal-transparent').remove()
        unless result
          @send 'pushAlert', 'alert', 'Uh-oh', "You have entered wrong password :("

    close: ->
      @set 'checkPrivate', false
      @set 'checkChecked', false
      $('.modal-transparent').remove()

    findPosts: ->
      @set 'isAllPosts', true
      @set 'isAllEvents', false
      @set 'isAllMedias', false

    findEvents: ->
      @set 'isAllPosts', false
      @set 'isAllEvents', true
      @set 'isAllMedias', false

    findMedias: ->
      @set 'isAllPosts', false
      @set 'isAllEvents', false
      @set 'isAllMedias', true

    backToSearch: ->
      @set 'isAllPosts', false
      @set 'isAllEvents', false
      @set 'isAllMedias', false

# validate password

  basicPasswordValidation: (->
    @set 'passwordWithLoginPasswordValidation', null
    if @get('password').length < 6
      return Yostalgia.InputValidation.create
        failed: true
        reason: 'Your password is too short'

    @passwordCheckWithLoginPassword()
  ).property('password')

  passwordCheckWithLoginPassword: Yostalgia.debounce(->
    Yostalgia.SearchResult.validateWithUserPassword(@get('password'), @session.get('user.id')).then (result) =>
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

  # validate confirm password

  passwordConfirmationValidation: (->
    return if @blank 'confirm_password'

    if @get('password') != @get('confirm_password')
      return Yostalgia.InputValidation.create
        failed: true
        reason: 'Your password doesnt match with confirm password'

    return Yostalgia.InputValidation.create(ok: true)
  ).property('password', 'confirm_password')

# bindings

  submitDisabled: (->
    return true if @get('passwordValidation.failed')
    return true if @get('passwordConfirmationValidation.failed')
    false
  ).property(
    'passwordValidation.failed',
    'passwordConfirmationValidation.failed')

  memoriesGreaterThanFive: (->
    @get('posts.length') > 5
  ).property('posts')

  mediasGreaterThanFive: (->
    @get('mediaPosts.length') > 5
  ).property('mediaPosts')

  eventsGreaterThanFive: (->
    @get('events.length') > 5
  ).property('events')

  queryIsBlank: (->
    Ember.isEmpty @get('query')
  ).property('query')

  queryChanged: (->
    @set 'isLoading', true
    @set 'isAllPosts', false
    @set 'isAllEvents', false
    @set 'isAllMedias', false
    if @get 'queryIsBlank'
      @set 'isLoading', false
      @set 'model', null
    else
      @performSearch()
  ).observes('query')

  checkedChange: (->
    @set 'isLoading', true
    if !@get('checkChecked')
      @set 'checkPrivate', false
      @set 'password', ""
      @set 'confirm_password', ""
      @performSearch()
    else
      Yostalgia.SearchResult.isExistInSearch(@session.get('user.id')).then (result) =>
        @set 'isExistInSearch', result
        @set 'isLoading', false
  ).observes('checkChecked')

  performSearch: Yostalgia.debounce(->
    unless @get('queryIsBlank')
      @set 'count', @get('count') + 1
      @get('store').find('searchResult', @get('query')+'?chk_private='+@get('checkPrivate')+'&count='+@get('count')).then (searchResult) =>
        @set 'model', searchResult
        @set 'isLoading', false
  , 200)
