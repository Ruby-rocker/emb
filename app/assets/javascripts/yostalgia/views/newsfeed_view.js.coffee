Yostalgia.NewsfeedView = Yostalgia.View.extend
  classNames: ['container', 'clearfix', 'newsfeed']

  actions:
    reloadLayout: Yostalgia.debounce(->
      @reloadMasonry()
    , 50)

  didInsertElement: ->
    $('body').addClass('background-alt')
    $('.posts').on 'scroll', $.proxy(@didScroll, @)
    Ember.run.scheduleOnce 'afterRender', @, ->
      $('#posts').masonry
        itemSelector: '.feed-item'

  willDestroyElement: ->
    $('body').removeClass('background-alt')
    $('.posts').off 'scroll', $.proxy(@didScroll, @)

  didScroll: ->
    if @isScrolledToBottom() && @get('controller.morePages')
      @get('controller').send('loadNextPage')

  isScrolledToBottom: ->
    distanceToViewPortTop = $('.posts ul').outerHeight() - $('.posts').height()
    viewPortTop = $('.posts').scrollTop()

    if viewPortTop == 0
      return false

    viewPortTop - distanceToViewPortTop >= 0

  reloadMasonry: ->
    if $('#posts').length
      $('#posts').masonry('reload')

  # scroll back to top when newsfeed is reloaded
  reloaded: (->
    if @get('controller.page') == 1
      $('.posts').scrollTop(0)
  ).observes('controller.page')
