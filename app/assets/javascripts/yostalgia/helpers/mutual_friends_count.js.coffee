Ember.Handlebars.helper 'mutualFriendsCount', (user, options) ->
  # TODO: we shouldn't be using private methods here. Find way to inject
  #   'session:main' or move the auth check out of helpers
  session = Yostalgia.__container__.lookup('session:main')
  if session.get('isAuthenticated')
    currentUser = session.get('user.content')
    mutualFriendIds = Yostalgia.Utilities.mutualFriendIds(currentUser, user)
    mutualFriendIds.get('length')
