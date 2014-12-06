Yostalgia.NotificationBaseController = Yostalgia.ObjectController.extend

  actions:
    notificationClicked: ->
      notification = @get('content')
      notification.set('clicked', true)
      notification.set('read', true)
      notification.save()

      @send('transitionToItem')
