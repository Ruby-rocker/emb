Yostalgia.ConversationMessageView = Yostalgia.View.extend

  templateName: 'conversation/message'

  tagName: 'li'
  classNameBindings: [':message-preview', 'controller.unread']

  didInsertElement: ->
    @_super()
    Ember.run.scheduleOnce 'afterRender', @, ->
      @get('parentView').messageAdded(@$())
