Yostalgia.EventPostsController = Yostalgia.ArrayController.extend

  needs: ['event']

  event: Ember.computed.alias 'controllers.event.model'
  canPost: Ember.computed.alias 'controllers.event.canPost'

  sortProperties: ['postedAt']
  sortAscending: false

  displayUserOnFeedItems: true
