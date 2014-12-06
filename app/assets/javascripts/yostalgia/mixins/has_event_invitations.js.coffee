Yostalgia.HasEventInvitations = Ember.Mixin.create

  eventInvitations: DS.hasMany('eventInvitation')

  pendingInvites: (->
    @get('eventInvitations').filter (invite) ->
      invite.get('pending') == true
  ).property('eventInvitations.@each.pending')

  acceptedInvites: (->
    @get('eventInvitations').filter (invite) ->
      invite.get('accepted') == true
  ).property('eventInvitations.@each.accepted')

  declinedInvites: (->
    @get('eventInvitations').filter (invite) ->
      invite.get('declined') == true
  ).property('eventInvitations.@each.declined')
