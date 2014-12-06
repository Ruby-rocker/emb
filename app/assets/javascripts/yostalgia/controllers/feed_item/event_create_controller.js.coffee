Yostalgia.FeedItemEventCreateController = Yostalgia.ObjectController.extend

  event: Ember.computed.alias('trackable')

  displayUser: (->
    @get('parentController.displayUserOnFeedItems')
  ).property('parentController.displayUserOnFeedItems')

  truncatedDescription: (->
    Yostalgia.Utilities.truncate(@get('event.description'), 198)
  ).property('event.description')

  isTruncated: (->
    Yostalgia.Utilities.isTruncated(@get('truncatedDescription'))
  ).property('truncatedDescription')
