Yostalgia.UserFriendsItemController = Yostalgia.ObjectController.extend

  actions:
    addFriend: ->
      if !@session.get('isAuthenticated')
        @send 'pushAlert', 'alert', 'You must be signed in to add friends'
        return
      if !@blank 'friendship'
        @send 'pushAlert', 'warning', "Oops, you're already friends!"
        return

      @session.get('user').then (user) =>
        friendship =
          pending: true
          sender: user
          receiver: @get 'model'

        friendship = @get('store').createRecord('friendship', friendship)
        friendship.save().then (friendship) =>
          @send 'pushAlert', 'success', 'Friend request sent'
        , (error) =>
          friendship.rollback()
          @send 'pushAlert', 'alert', 'Uh-oh', "Something went wrong :("
          console.log error

  friendship: (->
    if @session.get('isAuthenticated') && @session.get('user.friendships.length')
      friendships = @session.get('user.friendships').filter (friendship) =>
        friendship.get('sender.id') == @get('id') || friendship.get('receiver.id') == @get('id')
      return friendships.get('firstObject')
    null
  ).property(
    'session.isAuthenticated',
    'session.user.friendships.@each',
    'id')

  hasPendingSentFriendship: (->
    if @session.get('isAuthenticated') && @session.get('user.content')
      return @session.get('user.pendingSentFriends').contains(@get('model'))
    false
  ).property('session.isAuthenticated', 'session.user.pendingSentFriends.@each', 'model')

  hasPendingReceivedFriendship: (->
    if @session.get('isAuthenticated') && @session.get('user.content')
      return @session.get('user.pendingReceivedFriends').contains(@get('model'))
    false
  ).property('session.user.pendingReceivedFriends.@each', 'model')

  isFriend: (->
    !@blank('friendship') and !@get('friendship.pending')
  ).property('friendship.pending')

  canFriend: (->
    if @get('isFriend') or @get('hasPendingSentFriendship') or @get('hasPendingReceivedFriendship')
      return false
    true
  ).property('isFriend', 'hasPendingSentFriendship', 'hasPendingReceivedFriendship')

