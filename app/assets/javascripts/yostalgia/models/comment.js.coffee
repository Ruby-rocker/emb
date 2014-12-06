Yostalgia.Comment = Yostalgia.Model.extend

  user: DS.belongsTo 'user', async: true, readOnly: true
  #commentable: DS.belongsTo 'commentable', inverse: 'comments', polymorphic: true
  commentable: DS.belongsTo('commentable', { polymorphic: true })

  body:       DS.attr 'string'
  bodyHtml:   DS.attr 'string', readOnly: true
  createdAt:  DS.attr 'date', readOnly: true
