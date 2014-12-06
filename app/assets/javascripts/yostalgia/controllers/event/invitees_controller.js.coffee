Yostalgia.EventInviteesController = Yostalgia.ObjectController.extend

  needs: ['event']

  event: Ember.computed.alias 'model'
  canUninviteFriends: Ember.computed.alias('controllers.event.canUninviteFriends')

  actions:
    removeInvite: (invite) ->
      return if !@get 'canUninviteFriends'

      invite.deleteRecord()
      invite.save().then =>
        invite.get('user.profile').then (profile) =>
          @send 'pushAlert', 'warning', "#{profile.get('fullName')} has been un-invited"
      , (error) =>
        invite.rollback()
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong'
        console.log error

  numberGoing: (->
    @get('acceptedInvites.length') + 1
  ).property('acceptedInvites.length')
