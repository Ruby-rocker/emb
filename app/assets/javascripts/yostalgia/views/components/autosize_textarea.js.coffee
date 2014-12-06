Yostalgia.AutosizeTextareaComponent = Ember.TextArea.extend
  didInsertElement: ->
    @$().autosize()
    @_super.apply this, arguments

  willDestroyElement: ->
    @$().trigger('autosize.destroy')
    @_super.apply this, arguments
