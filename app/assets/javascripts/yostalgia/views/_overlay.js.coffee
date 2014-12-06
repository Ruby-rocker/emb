Yostalgia.OverlayView = Yostalgia.View.extend

  didInsertElement: ->
    $('body').on 'keyup.overlay', (event) =>
      if event.keyCode == 27 && !$(event.target).parents('.mentions-input').length
        @get('controller').send('close')

  willDestroyElement: ->
    $('body').off('keyup.overlay')
