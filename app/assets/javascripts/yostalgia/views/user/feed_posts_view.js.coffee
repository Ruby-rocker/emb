Yostalgia.UserFeedPostsView = Yostalgia.View.extend
  classNames: ['posts-container']

  templateName: 'user/feed_posts'

  actions:
    reloadLayout: Yostalgia.debounce(->
      @reloadMasonry()
    , 50)

  didInsertElement: ->
    Ember.run.scheduleOnce 'afterRender', @, ->
      $('#posts').masonry
        itemSelector: '.feed-item'

  reloadMasonry: ->
    if $('#posts').length
      $('#posts').masonry('reload')
