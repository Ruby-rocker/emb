Yostalgia.ConversationListItemController = Yostalgia.ObjectController.extend

  otherUsers: Ember.computed.filter 'users', (user) ->
    user.get('id') != @session.get 'user.id'

  userNames: Ember.computed.mapBy('otherUsers', 'profile.fullName')

  userNamesList: (->
    @get('userNames').join(', ')
  ).property('userNames.@each')
