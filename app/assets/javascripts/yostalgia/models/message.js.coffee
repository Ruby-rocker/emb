Yostalgia.Message = Yostalgia.Model.extend

  conversation: DS.belongsTo 'conversation'
  user: DS.belongsTo 'user', readOnly: true
  recipients: DS.hasMany 'user'

  body: DS.attr 'string'
  bodyHtml: DS.attr 'string', readOnly: true
  unread: DS.attr 'boolean'
  createdAt: DS.attr 'date', readOnly: true
