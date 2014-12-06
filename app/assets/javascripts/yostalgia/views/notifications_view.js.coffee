Yostalgia.NotificationsView = Yostalgia.OverlayView.extend
  elementId: 'notifications_overlay'
  classNames: ['modal']

  didInsertElement: ->
    @_super()
    @get('controller.controllers.application').set('notificationsShown', true)
    @$('.modal-left').on 'scroll', $.proxy(@didScroll, @)

  willDestroyElement: ->
    @_super()
    @get('controller.controllers.application').set('notificationsShown', false)
    @$('.modal-left').off 'scroll', $.proxy(@didScroll, @)

  didScroll: ->
    if @isScrolledToBottom()
      @get('controller').send('loadNextPage')

  isScrolledToBottom: ->
    content = @$('.notifications')
    container = @$('.modal-left')
    scrollTop = container.scrollTop()

    if scrollTop == 0
      return false

    scrollTop >= content.outerHeight() - container.height()
