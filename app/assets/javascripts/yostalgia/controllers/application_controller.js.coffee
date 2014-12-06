Yostalgia.ApplicationController = Ember.Controller.extend

  isMarketing: false
  currentRoute: null
  notificationsShown: false

  alertMessages: Em.A()
  checkPrivacy: false

  counts: null
  unreadNotificationCount: Ember.computed.alias 'counts.unreadNotifications'
  pendingInviteCount: Ember.computed.alias 'counts.pendingInvitations'
  pendingFriendshipCount: Ember.computed.alias 'counts.pendingReceivedFriendships'

  unreadConversationsCount: Ember.computed.alias 'counts.unreadConversations'

  search: ''

  pageHasFocus: true

  actions:
    focusIn: ->
      @set 'pageHasFocus', true
      if @session.get 'isAuthenticated'
        @refreshNotificationCounts()
        @startPollingNotificationCount()
        @stopInactivityTimer()

    focusOut: ->
      @set 'pageHasFocus', false
      if @session.get 'isAuthenticated'
        # using start as it changes interval
        @startPollingNotificationCount()
        @startInactivityTimer()


  onNewsfeed: (->
    if @get('currentRouteName') == 'newsfeed.index'
      true
    else
      false
  ).property('currentRouteName')


  # clean up alert message list when they are all closed
  alertMessagesWereClosed: (->
    alertMessages = @get('alertMessages')
    return if !alertMessages.length
    if @get('alertMessages').isEvery('closed')
      @set 'alertMessages', Em.A()
  ).observes('alertMessages.@each.closed')

  # start our polling if a user is signed in
  userSignedIn: (->
    # TODO: set user data on Raven for error reporting
    if @get 'session.isAuthenticated'
      @refreshNotificationCounts()
      @startPollingNotificationCount()
  ).observes('session.isAuthenticated').on('init')


  # navigation counts

  refreshNotificationCounts: ->
    if Ember.isEmpty @get('counts')
      @get('store').find('notificationCount', 'current').then (counts) =>
        @set 'counts', counts
    else
      @get('counts').reload()

  refreshNotificationCountPeriod: (->
    if @get 'pageHasFocus'
      15 * 1000
    else
      60 * 1000
  ).property('pageHasFocus')

  notificationsCount: (->
    @get('unreadNotificationCount') +
    @get('pendingInviteCount') +
    @get('pendingFriendshipCount')
  ).property(
    'unreadNotificationCount',
    'pendingInviteCount',
    'pendingFriendshipCount')

  startPollingNotificationCount: ->
    console.log 'started polling notification counts'
    pollNotificationCountTimer = @get 'pollNotificationCountTimer'
    clearInterval pollNotificationCountTimer if pollNotificationCountTimer
    pollNotificationCountTimer = setInterval =>
      @refreshNotificationCounts()
    , @get 'refreshNotificationCountPeriod'
    @set 'pollNotificationCountTimer', pollNotificationCountTimer

  stopPollingNotificationCount: ->
    console.log 'stopped polling notification counts'
    pollNotificationCountTimer = @get 'pollNotificationCountTimer'
    clearInterval pollNotificationCountTimer if pollNotificationCountTimer
    @set 'pollNotificationCountTimer', null

  startInactivityTimer: ->
    console.log 'starting inactivity time for notification counts'
    inactivityTimer = @get('inactivityTimer')
    Ember.run.cancel inactivityTimer if inactivityTimer
    inactivityTimer = Ember.run.later @, ->
      @stopPollingNotificationCount()
    , 10 * 60 * 1000
    @set 'inactivityTimer', inactivityTimer

  stopInactivityTimer: ->
    inactivityTimer = @get('inactivityTimer')
    Ember.run.cancel inactivityTimer if inactivityTimer
    @set 'inactivityTimer', null


  # navigation highlights

  isHome: (->
    @get('currentRoute') == 'home'
  ).property('currentRoute')

  isNewsfeed: (->
    @get('currentRoute') == 'newsfeed'
  ).property('currentRoute')

  isProfile: (->
    @get('currentRoute') == 'profile'
  ).property('currentRoute')

  isMessages: (->
    @get('currentRoute') == 'messages'
  ).property('currentRoute')

  isSearch: (->
    @get('currentRoute') == 'search'
  ).property('currentRoute')

  # observers

  isProfileRoute: (->
    if !@get('isProfile')
      @set 'checkPrivacy', false
  ).observes('currentRoute')
