Yostalgia.NotificationListController = Yostalgia.ArrayController.extend

  needs: ['notifications']

  sortProperties: ['createdAt']
  sortAscending: false

  isLoadingNotifications: Ember.computed.alias 'controllers.notifications.isLoadingNotifications'
