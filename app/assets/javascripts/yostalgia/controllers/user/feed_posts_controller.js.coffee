Yostalgia.UserFeedPostsController = Yostalgia.ObjectController.extend

  needs: ['user', 'userFeed', 'application']

  user: Ember.computed.alias 'controllers.user.model'
  viewingSelf: Ember.computed.alias 'controllers.user.viewingSelf'

  passwordWithLoginPasswordValidation: null
  password: ""
  confirm_password: ""
  isExistInSearch: false
  isLoading: false
  currentDate: null
  checkChecked: false
  checkPrivate: Ember.computed.alias 'controllers.application.checkPrivacy'
  newDate: null
  previous: false
  next: false

  ### actions ###

  actions:
    gotoPrevDate: ->
      @set 'previous', true
      @set 'next', false
      @transitionToNewDate @get('prevAvailableDate')

    gotoNextDate: ->
      @set 'previous', false
      @set 'next', true
      @transitionToNewDate @get('nextAvailableDate')

    checkPassword: ->
      Yostalgia.SearchResult.checkPassword(@get('password'), @session.get('user.id')).then (result) =>
        @set 'checkPrivate', result
        @set 'checkChecked', result
        @transitionToRoute 'user_feed.posts', @get('user'), 'today'
        $('.modal-transparent').remove()
        unless result
          @send 'pushAlert', 'alert', 'Uh-oh', "You have entered wrong password :("

    createSearchPassword: ->
      Yostalgia.SearchResult.createSearchPassword(@get('password'), @session.get('user.id')).then (result) =>
        $('.modal-transparent').remove()
        unless result
          @send 'pushAlert', 'alert', 'Uh-oh', "You have entered wrong password :("

    close: ->
      @set 'checkChecked', @get('checkPrivate')
      $('.modal-transparent').remove()

  ### properties ###

  selectedDateDisplay: (->
    Yostalgia.Utilities.simpleDateDisplay(@get('currentDate'))
  ).property('currentDate')

  emptyFeedText: (->
    firstName = @get('user.profile.firstName')
    if @get('selectedDateDisplay') == 'Today'
      "#{firstName} hasn't posted anything yet today"
    else if @get('currentDate') < new Date()
      "Looks like #{firstName} had an uneventful day, nothing to see here!"
    else
      "#{firstName} doesn't have anything planned yet for #{@get('selectedDateDisplay').toLowerCase()}"
  ).property('user.profile.firstName', 'currentDate')

  nextNavDisabled: (->
    return true if !@get('currentDate')
    isToday = Yostalgia.Utilities.isToday @get('currentDate')
    isToday || !moment(@get('nextAvailableDate')).isValid()
  ).property('currentDate', 'nextAvailableDate')

  prevNavDisabled: (->
    !moment(@get('prevAvailableDate')).isValid()
  ).property('prevAvailableDate')

  allActivities: (->
    @get('activities')
  ).property('activities')

  isCurrentUser: (->
    @session.get('user.content.id').toString() == @get('user.id').toString()
  ).property('user')

  ### observers ###

  changeActivities: (->
    @get('allActivities').set @get('activities')
  ).observes('checkPrivate')

  checkedChange: (->
    @set 'isLoading', true
    if !@get('checkChecked')
      @set 'checkPrivate', false
      @set 'password', ""
      @set 'confirm_password', ""
    else
      Yostalgia.SearchResult.isExistInSearch(@session.get('user.id')).then (result) =>
        @set 'isExistInSearch', result
        @set 'isLoading', false
  ).observes('checkChecked')

  changeActivities: (->
    @transitionToNewDate @get('model.currentDate')
  ).observes('checkPrivate')

  modelChanged: (->
    @set 'currentDate', @get('model.currentDate')
  ).observes('model')

  changeDate: (->
    @transitionToNewDate @get('newDate')
  ).observes('newDate')

  ### methods ###

  transitionToNewDate: (newDate) ->
    if Yostalgia.Utilities.isToday newDate
      newDateString = 'today'
    else
      newDateString = moment(newDate).format 'MM-DD-YYYY'
    @transitionToRoute 'user_feed.posts', @get('user'), newDateString


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
