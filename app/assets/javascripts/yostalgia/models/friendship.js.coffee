Yostalgia.Friendship = Yostalgia.Model.extend

  sender:     DS.belongsTo('user', { inverse: 'sentFriendships' })
  receiver:   DS.belongsTo('user', { inverse: 'receivedFriendships' })

  pending:    DS.attr('boolean')
