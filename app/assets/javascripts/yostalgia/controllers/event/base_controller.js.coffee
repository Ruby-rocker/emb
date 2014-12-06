Yostalgia.EventController = Yostalgia.ObjectController.extend

  selectedFriends: null

  actions:
    selectFriends: (selectedFriends) ->
      itemsToSave = []

      selectedFriends.forEach (selectedFriend) =>
        invite = @get('store').createRecord('eventInvitation')
        invite.set 'user', selectedFriend
        invite.set 'event', @get('model')
        itemsToSave.pushObject invite

      Ember.RSVP.all(itemsToSave.invoke('save')).then =>
        @send 'pushAlert', 'success', 'Invites sent'

    joinEvent: ->
      return unless @get 'canJoin'
      invite = @get 'invite'
      invite.set 'accepted', true
      invite.set 'acceptanceConfirmedAt', new Date()
      invite.save().then (savedInvite) =>
        @set 'invite', savedInvite
      , (error) =>
        invite.rollback()
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong :('
        console.log error

    leaveEvent: ->
      return unless @get('canLeave')
      invite = @get 'invite'
      invite.set 'accepted', false
      invite.set 'acceptanceConfirmedAt', new Date()
      invite.save().then (savedInvite) =>
        @set 'invite', savedInvite
      , (error) =>
        invite.rollback()
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong :('
        console.log error

  invite: (->
    invites = @get('eventInvitations')
    invites.findBy('user.id', @session.get('user.id'))
  ).property('eventInvitations.@each', 'session.user.id')

  availableFriends: (->
    @session.get('user.friends').then (friends) =>
      invitees = @get('invitees')
      friends.filter (friend) ->
        !invitees.contains(friend)
  ).property('session.user.friends.@each', 'invitees.@each')


  canPost: (->
    @get('isOwner') || @get('isInvited')
  ).property('isOwner', 'isInvited')

  canJoin: (->
    !@get('isOwner') && @get('isInvited') && !@get('isGoing')
  ).property('isOwner', 'isInvited', 'isGoing')

  canLeave: (->
    !@get('isOwner') && @get('isGoing')
  ).property('isOwner', 'isGoing')


  canInviteFriends: (->
    @get 'isOwner'
  ).property('isOwner')

  canUninviteFriends: (->
    @get 'isOwner'
  ).property('isOwner')

  canEdit: (->
    @get 'isOwner'
  ).property('isOwner')


  isOwner: (->
    @get('user.id') == @session.get('user.id')
  ).property('session.user.id', 'user.id')

  isInvited: (->
    @get('isOwner') || !@blank 'invite'
  ).property('isOwner', 'invite')

  isGoing: (->
    @get('isOwner') || @get('invite.accepted')
  ).property('isOwner', 'invite.accepted')

  isNotGoing: (->
    !@get('isOwner') || @get('invite.declined')
  ).property('isOwner', 'invite.declined')
