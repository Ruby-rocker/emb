Yostalgia.EachEventsComponent = Ember.Component.extend
	
	time: null
	event: null

	isSameDate: (->
		moment(@get('event').get('startTime')).format('MM-DD-YYYY') == moment(@get('time')).format('MM-DD-YYYY')
	).property('event', 'time')