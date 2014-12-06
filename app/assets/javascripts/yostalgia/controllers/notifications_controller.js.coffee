Yostalgia.NotificationsController = Yostalgia.OverlayController.extend
  needs: 'application'

  pendingInvites: null

  isLoadingNotifications: false
  notifications: Em.A()
  timestamp: null
  page: null
  morePages: null

  init: ->
    @set 'pendingInvites', @get('store').filter 'eventInvitation', (invitation) =>
      invitation.get('pending') &&
      invitation.get('user.id') == @session.get('user.id')

  actions:
    loadNotifications: ->
      @set 'timestamp', new Date()
      @set 'isLoadingNotifications', true
      @loadNotifications()

    loadNextPage: ->
      if @get('morePages') && !@get('isLoadingNotifications')
        @set 'isLoadingNotifications', true
        @set 'page', @get('page') + 1
        @loadNotifications()

    setMetaData: (notifications) ->
      metadata = notifications.meta
      @set 'page', metadata.page
      @set 'morePages', if metadata.more_pages == 'yes' then true else false

    reset: ->
      @set 'isLoadingNotifications', false
      @set 'notifications', new Em.A()
      @set 'timestamp', null
      @set 'page', null
      @set 'morePages', null

    close: ->
      @markNotificationsAsRead()
      @send 'reset'
      @send 'closeOverlay'

    acceptFriendRequest: (friendship) ->
      friendship.set('pending', false)
      friendship.save().then =>
        @send 'pushAlert', 'success', 'Friend request accepted'
      , (error) =>
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong :-('
        console.log error

    deleteFriendRequest: (friendship) ->
      friendship.deleteRecord()
      friendship.save().then =>
        @send 'pushAlert', 'warning', 'Friend request declined'
      , (error) =>
        friendship.rollback()
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong :('
        console.log error

    acceptInvite: (invitation) ->
      invitation.set 'accepted', true
      invitation.set 'acceptanceConfirmedAt', new Date()
      invitation.save().then (savedInvitation) =>
        @transitionToRoute 'event', savedInvitation.get('event')
      , (error) =>
        invitation.rollback()
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong :('
        console.log error

    declineInvite: (invitation) ->
      invitation.set 'accepted', false
      invitation.set 'acceptanceConfirmedAt', new Date()
      invitation.save().then (savedInvitation) =>
        @send 'pushAlert', 'warning', 'Event invite declined'
      , (error) =>
        invitation.rollback()
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong :('
        console.log error


  loadNotifications: ->
    @get('store').find('eventInvitation', pending: true)
    @get('store').find('notificationActivity', @get('loadNotificationOptions')).then (notifications) =>
      notifications.forEach (notification) =>
        unless @get('notifications').contains notification
          @get('notifications').pushObject notification
      @set 'isLoadingNotifications', false
      @send 'setMetaData', notifications

  loadNotificationOptions: (->
    page: @get('page')
    timestamp: @get('timestamp')
  ).property('page', 'timestamp')

  markNotificationsAsRead: ->
    notifications = @get('notifications').filterBy('read', false)
    notifications.forEach (notification) ->
      notification.set('read', true)

    # TODO: this should probably be done on the NotificationActivity model
    unreadCount = @get 'controllers.application.unreadNotificationCount'
    if unreadCount and !Ember.isEmpty(notifications)
      Ember.RSVP.all(notifications.invoke('save')).then =>
        @send 'refreshNotificationCounts'
