Yostalgia.ConversationView = Yostalgia.View.extend

  classNames: ['conversation-container']

  didInsertElement: ->
    @_super()
    @$('textarea').focus()
    @get('controller').on 'resetNewMessage', $.proxy(@resetNewMessage, @)

  willDestroyElement: ->
    @_super()
    @get('controller').off 'resetNewMessage', $.proxy(@resetNewMessage, @)

  resetNewMessage: ->
    Ember.run.scheduleOnce 'afterRender', @, ->
      if @$('textarea').length
        @$('textarea').focus().trigger('autosize.resize')
