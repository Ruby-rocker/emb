Yostalgia.SearchEventController = Yostalgia.ObjectController.extend

	needs: ['search']

	event: Ember.computed.alias('model')
