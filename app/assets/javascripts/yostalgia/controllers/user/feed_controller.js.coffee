Yostalgia.UserFeedController = Yostalgia.ObjectController.extend

  needs: ['user']
  user: Ember.computed.alias 'controllers.user.model'
