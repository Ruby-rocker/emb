Yostalgia.EventPostFormOverlayController = Yostalgia.PostFormOverlayController.extend

  showPrivateToggle: false

  create: (event) ->
    post = @get('store').createRecord('post')
    post.set 'event', event
    @set 'model', post
