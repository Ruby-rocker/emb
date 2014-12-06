Yostalgia.Event = Yostalgia.Attachable.extend Yostalgia.HasEventInvitations,

  user:       DS.belongsTo 'user', async: true, readOnly: true
  coverPhoto: DS.belongsTo 'attachment', readOnly: true
  posts:      DS.hasMany 'post', async: true

  title:      DS.attr 'string'
  body:       DS.attr 'string'
  bodyHtml:   DS.attr 'string', readOnly: true
  location:   DS.attr 'string'
  startTime:  DS.attr 'date'
  endTime:    DS.attr 'date'
  isPrivate:  DS.attr 'boolean'

  invitees: Ember.computed.map 'eventInvitations', (invite) ->
    invite.get 'user'

  pendingInvitees: (->
    invites = @get 'pendingInvites'
    invitees = invites.map (invite) ->
      invite.get('user')

    ap = Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
      content: invitees
      sortProperties: ['profile.fullName']

    ap.get('arrangedContent')
  ).property('pendingInvites.@each')

  acceptedInvitees: (->
    invites = @get 'acceptedInvites'
    invitees = invites.map (invite) ->
      invite.get('user')

    ap = Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
      content: invitees
      sortProperties: ['profile.fullName']

    ap.get('arrangedContent')
  ).property('acceptedInvites.@each')

  declinedInvitees: (->
    invites = @get 'declinedInvites'
    invitees = invites.map (invite) ->
      invite.get('user')

    ap = Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
      content: invitees
      sortProperties: ['profile.fullName']

    ap.get('arrangedContent')
  ).property('declinedInvites.@each')
