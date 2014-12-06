Yostalgia.SearchUserController = Yostalgia.ObjectController.extend

  mutualFriendCount: (->
    currentUser = @session.get('user.content')
    Yostalgia.Utilities.mutualFriendIds(@get('model'), currentUser).get('length')
  ).property('friends.@each', 'session.user.content')
