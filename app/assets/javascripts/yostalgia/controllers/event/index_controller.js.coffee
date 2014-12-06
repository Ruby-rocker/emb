Yostalgia.EventIndexController = Yostalgia.ObjectController.extend

  event: Ember.computed.alias 'model'

  startDay: (->
    moment(@get('startTime')).format('DD')
  ).property('startTime')

  startMonth: (->
    moment(@get('startTime')).format('MMM')
  ).property('endTime')

  displayEndDate: (->
    startTime = moment(@get 'startTime').startOf('day')
    endTime = moment(@get 'endTime').startOf('day')
    !startTime.isSame(endTime)
  ).property('startTime', 'endTime')

  endDay: (->
    moment(@get('endTime')).format('DD')
  ).property('endTime')

  endMonth: (->
    moment(@get('endTime')).format('MMM')
  ).property('endTime')

  timePeriod: (->
    startTime = moment(@get('startTime')).format('HH:mm')
    endTime = moment(@get('endTime')).format('HH:mm')
    "#{startTime} - #{endTime}"
  ).property('startTime', 'endTime')

  invitees: (->
    @get('acceptedInvitees').concat(@get('pendingInvitees'))
  ).property('acceptedInvitees.@each', 'pendingInvitees.@each')
