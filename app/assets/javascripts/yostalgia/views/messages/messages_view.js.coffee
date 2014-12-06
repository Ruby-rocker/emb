Yostalgia.MessagesView = Yostalgia.View.extend

  didInsertElement: ->
    @_super()
    @$('.message-list ul').on 'scroll', $.proxy(@didScroll, @)
    unless typeof pageHiddenAttribute == undefined
      $(document).on visibilityChangeEvent, $.proxy(@handleVisibilityChange, @)

  willDestroyElement: ->
    @_super()
    @$('.message-list ul').off 'scroll', $.proxy(@didScroll, @)
    unless typeof pageHiddenAttribute == undefined
      $(document).off visibilityChangeEvent, $.proxy(@handleVisibilityChange, @)

  didScroll: ->
    container = @$('.message-list ul')
    scrollBottom = container[0].scrollHeight - container.height()
    if container.scrollTop() >= scrollBottom
      @get('controller').send('loadEarlierPage')

  handleVisibilityChange: ->
    if document[pageHiddenAttribute]
      @get('controller').send 'focusOut'
    else
      @get('controller').send 'focusIn'
