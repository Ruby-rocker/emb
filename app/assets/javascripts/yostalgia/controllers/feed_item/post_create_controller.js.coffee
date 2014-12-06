Yostalgia.FeedItemPostCreateController = Yostalgia.ObjectController.extend

  needs: ['application']

  post: (->
    if @get 'trackable'
      @get 'trackable'
    else
      @get 'model'
  ).property('model', 'trackable')

  displayUser: (->
    @get('parentController.displayUserOnFeedItems')
  ).property('parentController.displayUserOnFeedItems')

  displayEvent: (->
    !@blank('post.event') && !@get('controllers.application.onEventFeed')
  ).property('post.event', 'controllers.application.onEventFeed')

  truncatedBody: (->
    Yostalgia.Utilities.truncate(@get('post.body'), 198)
  ).property('post.body')

  isTruncated: (->
    Yostalgia.Utilities.isTruncated(@get('truncatedBody'))
  ).property('truncatedBody')
