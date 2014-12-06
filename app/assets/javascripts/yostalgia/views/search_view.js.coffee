Yostalgia.SearchView = Yostalgia.View.extend
  classNames: ['container', 'clearfix', 'search-results']

  didInsertElement: ->
    $('body').addClass('background-alt')

  willDestroyElement: ->
    $('body').removeClass('background-alt')
