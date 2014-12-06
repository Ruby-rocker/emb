Yostalgia.SearchMediaPostController = Yostalgia.ObjectController.extend

	needs: ['search']

	post: Ember.computed.alias('model')
