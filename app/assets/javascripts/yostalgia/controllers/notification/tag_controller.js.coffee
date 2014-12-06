Yostalgia.NotificationTagController = Yostalgia.NotificationBaseController.extend

  post: Ember.computed.alias('trackable')
  event: Ember.computed.alias('trackable.event')

  actions:
    transitionToItem: ->
      @transitionToRoute 'post', @get('post')

  postText: (->
    text = if !@blank('post.title') then @get('post.title') else @get('post.body')
    if !Ember.isEmpty text
      Yostalgia.Utilities.truncate(text, 50)
  ).property('post.title', 'post.body')
