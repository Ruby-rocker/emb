Yostalgia.EventInvitation = Yostalgia.Model.extend

  user: DS.belongsTo('user')
  event: DS.belongsTo('event')

  accepted: DS.attr('boolean', defaultValue: false)
  acceptanceConfirmedAt: DS.attr('date')
  createdAt: DS.attr('date')

  pending: (->
    !@get('accepted') && @blank 'acceptanceConfirmedAt'
  ).property('accepted', 'acceptanceConfirmedAt')

  declined: (->
    !@get('accepted') && !@blank 'acceptanceConfirmedAt'
  ).property('accepted', 'acceptanceConfirmedAt')
