Yostalgia.FriendSelectorModalController = Yostalgia.ArrayController.extend

  actionController: null

  sortProperties: ['profile.fullName']

  isLoading: false
  actionText: null

  actions:
    toggleFriend: (friend) ->
      friend.set 'isSelected', !friend.get('isSelected')

    save: ->
      selected = @get('model').filterBy('isSelected', true)
      @get('actionController').send 'selectFriends', selected
      @send 'close'

    close: ->
      @get('model').forEach (user) ->
        user.set 'isSelected', false
      @send 'closeModal'
