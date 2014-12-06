Yostalgia.Authentication = DS.Model.extend

  user: DS.belongsTo('user')
  provider: DS.attr('string')
