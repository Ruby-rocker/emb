Yostalgia.MemoryLane = Yostalgia.Model.extend

  date: DS.attr 'date'
  postsCount: DS.attr 'number', default: 0
  eventsCount: DS.attr 'number', default: 0

  user: DS.belongsTo 'user', async: true
  profileVersion: DS.belongsTo 'profileVersion'
  activities: DS.hasMany 'userfeedActivity'

  flashbackDate: (->
    moment.parseZone(@get('date')).format 'MM-DD-YYYY'
  ).property('date')
