Yostalgia.User = Yostalgia.Model.extend Yostalgia.HasEventInvitations,

  username:   DS.attr 'string'
  email:      DS.attr 'string'
  password:   DS.attr 'string'

  authentications:  DS.hasMany 'authentication'

  profile:          DS.belongsTo 'profile', async: true
  posts:            DS.hasMany 'post', async: true
  attachments:      DS.hasMany 'attachment', async: true
  friends:          DS.hasMany 'user', async: true
  events:           DS.hasMany 'event', async: true
  notifications:    DS.hasMany 'notificationActivity', async: true

  sentFriendships:      DS.hasMany 'friendship', async: true, inverse: 'sender'
  receivedFriendships:  DS.hasMany 'friendship', async: true, inverse: 'receiver'
  friendships:  Ember.computed.uniq 'sentFriendships', 'receivedFriendships'

  profilePhotoCount:    DS.attr 'number', readOnly: true
  coverPhotoCount:      DS.attr 'number', readOnly: true
  generalPhotoCount:    DS.attr 'number', readOnly: true

  emailOnFriendRequest: DS.attr 'boolean'
  emailOnComment:       DS.attr 'boolean'
  emailOnLike:          DS.attr 'boolean'
  emailOnEventInvite:   DS.attr 'boolean'
  emailOnEventPost:     DS.attr 'boolean'
  emailOnMessage:       DS.attr 'boolean'
  emailOnMention:       DS.attr 'boolean'
  emailOnTag:           DS.attr 'boolean'

  isSelected: false

  pendingReceivedFriendships: (->
    @get('receivedFriendships').filter (friendship) ->
      friendship.get('pending') == true
  ).property('receivedFriendships.@each.pending')

  pendingReceivedFriends: (->
    friends = Ember.A()
    @get('pendingReceivedFriendships').forEach (friendship) ->
      friends.push friendship.get('sender')
    return friends
  ).property('pendingReceivedFriendships.@each')

  pendingSentFriends: (->
    friends = Ember.A()
    @get('sentFriendships').forEach (friendship) ->
      if friendship.get('pending')
        friends.push friendship.get('receiver')
    return friends
  ).property('sentFriendships', 'sentFriendships.@each.pending')

  facebookConnected: (->
    @get('authentications').filterProperty('provider', 'facebook').length > 0
  ).property('authentications.@each.provider')

  twitterConnected: (->
    @get('authentications').filterProperty('provider', 'twitter').length > 0
  ).property('authentications.@each.provider')
