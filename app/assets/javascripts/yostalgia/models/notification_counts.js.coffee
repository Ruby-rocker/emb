Yostalgia.NotificationCount = Yostalgia.Model.extend

  user: DS.belongsTo 'user'

  unreadConversations: DS.attr 'number'
  unreadNotifications: DS.attr 'number'
  pendingReceivedFriendships: DS.attr 'number'
  pendingInvitations: DS.attr 'number'
