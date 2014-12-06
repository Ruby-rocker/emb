Yostalgia.ComponentTestController = Ember.ObjectController.extend

  mentionsOneText: 'testing @[Kevin Ansfield](User:1)'
  mentionsTwoText: null

  selectedDate: null

  logDateChange: (->
    console.log @get('selectedDate')
  ).observes('selectedDate')

  selectedUsers: Ember.A()
  userSearchResults: Ember.A()

  actions:
    searchUsers: (term) ->
      unless Ember.isEmpty term
        @store.find('searchResult', term).then (searchResult) =>
          searchResult.get('users').then (users) =>
            @set 'userSearchResults', users.get('content').slice(0, 10)
