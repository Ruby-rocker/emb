Yostalgia.Notifiable = Yostalgia.Trackable.extend
  notifications: DS.hasMany 'notificationActivity', async: true, readOnly: true
