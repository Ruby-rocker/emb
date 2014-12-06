Yostalgia.ApplicationView = Ember.View.extend

  changePageClass: (->
    if @get 'controller.isMarketing'
      $('body').removeClass('application-page')
      $('body').addClass('marketing-page')
    else
      $('body').removeClass('marketing-page')
      $('body').addClass('application-page')
  ).observes('controller.isMarketing')

  didInsertElement: ->
    @_super()
    setTimeout =>
      flashAlerts.forEach (alert) =>
        @get('controller').send 'pushAlert', alert.type, alert.title, alert.text
    , 2000
    unless typeof pageHiddenAttribute == undefined
      $(document).on visibilityChangeEvent, $.proxy(@handleVisibilityChange, @)

  willDestroyElement: ->
    unless typeof pageHiddenAttribute == undefined
      $(document).off visibilityChangeEvent, $.proxy(@handleVisibilityChange, @)

  handleVisibilityChange: ->
    if document[pageHiddenAttribute]
      @get('controller').send 'focusOut'
    else
      @get('controller').send 'focusIn'
