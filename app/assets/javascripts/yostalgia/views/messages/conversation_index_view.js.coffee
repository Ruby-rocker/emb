Yostalgia.ConversationIndexView = Yostalgia.View.extend

  isScrolledUp: false

  didInsertElement: ->
    @_super()
    $('.conversation-body').on 'scroll', $.proxy(@didScroll, @)

  willDestroyElement: ->
    @_super()
    $('.conversation-body').off 'scroll', $.proxy(@didScroll, @)

  didScroll: ->
    container = $('.conversation-body')

    # ensure we don't jump to new messages if we're scrolled up
    if container.scrollTop() < container[0].scrollHeight - container.height()
      @set 'isScrolledUp', true
    else
      @set 'isScrolledUp', false

    # load earlier messages when we hit the top
    if container.scrollTop() == 0
      @get('controller').send('loadEarlierPage')

  isScrolledToBottom: ->
    container = $('.conversation-body')
    scrollTop = container.scrollTop()
    scrollHeight = container[0].scrollHeight

    return false if scrollTop == 0

    scrollTop >= scrollHeight - container.height()

  messageAdded: (message) ->
    $body = $('.conversation-body')

    if @get 'isScrolledUp'
      $body.scrollTop $body.scrollTop() + $(message).height()
    else
      $body.scrollTop $body[0].scrollHeight
