Yostalgia.UserPhotosView = Yostalgia.View.extend

  templateName: 'user/photos'

  didInsertElement: ->
    $(window).scrollTop @get('controller.scrollPosition')
    $(window).on 'scroll', $.proxy(@didScroll, @)

  willDestroyElement: ->
    $(window).off 'scroll', $.proxy(@didScroll, @)

  didScroll: ->
    Ember.run.debounce @, @checkScroll, 50

  checkScroll: ->
    @get('controller').set 'scrollPosition', $(window).scrollTop()

    if @isScrolledToBottom() && @get('controller.morePages')
      @get('controller').send('getMore')

  isScrolledToBottom: ->
    $(window).scrollTop() + $(window).height() == $(document).height()
