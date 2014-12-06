Yostalgia.EventPostsView = Yostalgia.View.extend
  classNames: ['container', 'clearfix', 'newsfeed', 'event-posts']

  actions:
    reloadLayout: Yostalgia.debounce(->
      @reloadMasonry()
    , 50)

  didInsertElement: ->
    $('body').addClass('background-alt')
    Ember.run.scheduleOnce 'afterRender', @, ->
      $('#posts').masonry
        itemSelector: '.feed-item'

  willDestroyElement: ->
    $('body').removeClass('background-alt')

  reloadMasonry: ->
    if $('#posts').length
      $('#posts').masonry('reload')
