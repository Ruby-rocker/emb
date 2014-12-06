Yostalgia.EventsOnTimeComponent = Ember.Component.extend

	time: null

	eventActivities: (->
		@get('parentView').get('controller').get('activities')
	).property('time')