Yostalgia.OverlayController = Yostalgia.ObjectController.extend

  actions:
    edit: (record) ->
      @set('model', record)

    save: ->
      @get('model').save().then (=>
        @send 'close'
      ), (error) =>
        @alerts.pushAlert('alert', 'Uh-oh!', 'Something went wrong when saving :(')
        console.log error

    close: ->
      model = @get('model')
      if model and model.get('isDirty')
        model.rollback()

      @send 'closeOverlay'

  shouldDisableSubmit: (->
    return !@get('isDirty') or @get('isSaving')
  ).property('isDirty', 'isSaving')
