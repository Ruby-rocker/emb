Yostalgia.AlertMessageView = Yostalgia.View.extend
  templateName: 'alert_message'

  classNameBindings: [
    ':alert-message',
    'content.type',
    'content.closed',
    'isOpaque'
  ]

  attributeBindings: ['style']

  timeoutId: null

  init: ->
    @_super()
    fn = (->
      @notifyPropertyChange 'style'
    ).bind(@)
    @set '_recomputeStyle', 'fn'
    $(window).bind('resize', fn)

  willDestroyElement: ->
    $(window).unbind 'resize', @get('_recomputeStyle')

  didInsertElement: ->
    callback = (->
      @send 'close'
    ).bind(@)
    @set 'timeoutId', setTimeout(callback, @get('hideAfterMs'))
    Ember.run.later @, (->
      @set 'isOpaque', true
    ), 1

  isOpaque: false

  hideAfterMs: 6000

  title: (->
    type = @get 'content.type'
    if @blank 'content.title'
      return 'Error' if type == 'alert'
      return 'Warning' if type == 'warn'
      return 'Success' if type == 'success'
    else
      @get 'content.title'
  ).property('content.title', 'content.type')

  style: (->
    alertMessages = @get('controller.alertMessages').rejectBy('closed')
    index = alertMessages.indexOf @get('content')
    viewportHeight = $(window).height()
    unitHeight = 80
    unitWidth = 320
    unitsPerColumn = Math.floor(viewportHeight / unitHeight)
    column = Math.floor(index / unitsPerColumn)
    row = index % unitsPerColumn

    return '' if index == -1 # not in list

    topPx = row * unitHeight
    rightPx = column * unitWidth

    return "top: #{topPx}px; right: #{rightPx}px"
  ).property('controller.alertMessages.@each.closed')

  iconType: (->
    type = @get('content.type')
    hash = {
      'alert': 'ss-caution',
      'warn': 'ss-alert'
      'success': 'ss-check'
    }
    return hash[type] || ''
  ).property('content.type')

  actions:
    close: ->
      @set 'isOpaque', false
      callback = (->
        @set 'content.closed', true
        clearTimeout @get('timeoutId')
      ).bind(@)
      setTimeout callback, 300
