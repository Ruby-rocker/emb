Yostalgia.UserIndexController = Yostalgia.ObjectController.extend

  needs: ['user']

  user: Ember.computed.alias('model')

  selectedDate: null
  attachments: null
  events: null

  actions:
    addFriend: ->
      if !@session.get('isAuthenticated')
        @send 'pushAlert', 'alert', 'You must be signed in to add friends'
        return
      if !@blank 'friendship'
        @send 'pushAlert', 'warning', "Oops, you're already friends!"
        return

      friendship =
        pending: true
        sender: @session.get 'user.content'
        receiver: @get 'user'

      friendship = @get('store').createRecord('friendship', friendship)
      friendship.save().then =>
        @send 'pushAlert', 'success', 'Friend request sent'
      , (error) =>
        friendship.rollback()
        @send 'pushAlert', 'alert', 'Uh-oh', "Something went wrong :("
        console.log error

    removeFriend: ->
      friendship = @get('friendship')

      friendship.deleteRecord()
      friendship.save().then =>
        @send 'pushAlert', 'warning', 'Friendship ended'
      , (error) =>
        friendship.rollback()
        @send 'pushAlert', 'alert', 'Uh-oh', "Something went wrong :("
        console.log error

    acceptRequest: ->
      friendship = @get('friendship')
      friendship.set('pending', false)
      friendship.save().then =>
        @send 'pushAlert', 'success', 'Friend request accepted'
      , (error) =>
        friendship.rollback()
        @send 'pushAlert', 'alert', 'Uh-oh', "Something went wrong :("
        console.log error

  friendship: (->
    if @session.get('isAuthenticated') && @session.get('user.friendships.length')
      friendships = @session.get('user.friendships').filter (friendship) =>
        friendship.get('sender.id') == @get('user.id') || friendship.get('receiver.id') == @get('user.id')
      return friendships.get('firstObject')
    null
  ).property(
    'session.isAuthenticated',
    'session.user.friendships.@each',
    'user.id')

  viewingSelf: (->
    @get('controllers.user.viewingSelf')
  ).property('controllers.user.viewingSelf')

  isFriend: (->
    !@blank('friendship') and !@get('friendship.pending')
  ).property('friendship.pending')

  showFeedLink: (->
    @get('isFriend') or @get('viewingSelf')
  ).property('isFriend', 'viewingSelf')

  showAttachments: (->
    (@get('viewingSelf') || @get('isFriend')) && @get('attachments.length')
  ).property('attachments.@each', 'viewingSelf', 'isFriend', 'attachments.length')

  showEvents: (->
    (@get('viewingSelf') || @get('isFriend')) && @get('events.length')
  ).property('events.@each', 'viewingSelf', 'isFriend')

  hasPendingSentFriendship: (->
    if @session.get('isAuthenticated') && @session.get('user.content')
      return @session.get('user.pendingSentFriends').contains(@get('user'))
    false
  ).property('session.isAuthenticated', 'session.user.pendingSentFriends.@each', 'user')

  hasPendingReceivedFriendship: (->
    if @session.get('isAuthenticated') && @session.get('user.content')
      return @session.get('user.pendingReceivedFriends').contains(@get('user'))
    false
  ).property('session.user.pendingReceivedFriends.@each', 'user')

  canFriend: (->
    if @get('isFriend') or @get('hasPendingSentFriendship') or @get('hasPendingReceivedFriendship')
      return false
    true
  ).property('isFriend', 'hasPendingSentFriendship', 'hasPendingReceivedFriendship')

  dateChanged: (->
    selectedDate = moment(@get('selectedDate'))
    today = moment().startOf('day')
    unless selectedDate.startOf('day').isSame(today)
      @transitionToRoute 'user.profile_version', selectedDate.format('MM-DD-YYYY')
  ).observes('selectedDate')

  selectedDateDisplay: (->
    Yostalgia.Utilities.simpleDateDisplay(moment())
  ).property('selectedDate')

  truncatedAboutMe: (->
    Yostalgia.Utilities.truncate(@get('profile.aboutMe'), 198)
  ).property('profile.aboutMe')
