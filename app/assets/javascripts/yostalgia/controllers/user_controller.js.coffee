Yostalgia.UserController = Yostalgia.ObjectController.extend

  # contentChanged: (->
  #   Ember.run.scheduleOnce 'afterRender', @, ->
  #     @send('closeOverlay')
  # ).observes('model')

  viewingSelf: (->
    if @session.get('isAuthenticated')
      return @session.get('user.id') == @get('model.id')
    false
  ).property('session.user.id', 'model.id')
