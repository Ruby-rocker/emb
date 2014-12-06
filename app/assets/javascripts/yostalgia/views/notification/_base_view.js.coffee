Yostalgia.NotificationBaseView = Yostalgia.View.extend

  tagName: 'li'
  classNameBindings: [':notification', 'controller.clicked:read:unread']

  click: ->
    @get('controller').send('notificationClicked')
