Yostalgia.Conversation = Yostalgia.Model.extend

  users:        DS.hasMany 'user', async: true, readOnly: true
  displayUser:  DS.belongsTo 'user', async: true, readOnly: true
  messages:     DS.hasMany 'message', async: true, readOnly: true

  previewText: DS.attr 'string', readOnly: true
  unread: DS.attr 'boolean'
  createdAt: DS.attr 'date', readOnly: true
  updatedAt: DS.attr 'date', readOnly: true

  markAsRead: ->
    @set 'unread', false
    @save()
