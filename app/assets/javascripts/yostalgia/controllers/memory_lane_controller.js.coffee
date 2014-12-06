Yostalgia.MemoryLaneController = Yostalgia.ObjectController.extend

  needs: ['userFeedPosts']
  isLoading: false
  displayUserOnFeedItems: false
  forUser: null

  checkPrivate: Ember.computed.alias 'controllers.userFeedPosts.checkPrivate'

  actions:
    refresh: ->
      @set 'isLoading', true
      tzOffset = moment().zone() # returns UTC difference from local...
      tzOffset = tzOffset - (tzOffset * 2) # so we inverse to get actual diff
      options =
        user_id: @get('forUser.id')
        tz_offset: tzOffset
      @store.find('memoryLane', options).then (memoryLanes) =>
        @set 'model', memoryLanes.get('lastObject')
        @set 'isLoading', false

  displayProfile: (->
    !Ember.isEmpty @get('date')
  ).property('date')

  showGeneralInfo: (->
    Ember.isEmpty @get('user')
  ).property('user')

  showUserHasNoContentInfo: (->
    @get('user') && !@get('date')
  ).property('user', 'date')

  showFlashback: (->
    @get('user') && @get('date')
  ).property('user', 'date')

  publicActivities: (->
    @get('activities').filterBy('trackablePrivacy', @get('checkPrivate').toString())
  ).property('activities', 'checkPrivate')

  observePublicActivities: (->
    @get('activities').filterBy('trackablePrivacy', @get('checkPrivate').toString())
  ).observes('activities', 'checkPrivate')
