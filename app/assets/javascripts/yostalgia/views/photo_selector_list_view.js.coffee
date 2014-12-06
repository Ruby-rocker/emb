Yostalgia.PhotoSelectorListView = Yostalgia.View.extend

  didInsertElement: ->
    $('.modal-dialog-body').on 'scroll', $.proxy(@didScroll, @)

  willDestroyElement: ->
    $('.modal-dialog-body').off 'scroll', $.proxy(@didScroll, @)

  didScroll: ->
    if @isScrolledToBottom()
      @get('controller').send('loadNextAlbumPage')

  isScrolledToBottom: ->
    distanceToViewPortTop = $('.modal-dialog-body ul').outerHeight() - $('.modal-dialog-body').height()
    viewPortTop = $('.modal-dialog-body').scrollTop()

    if viewPortTop == 0
      return false

    viewPortTop - distanceToViewPortTop >= 0
