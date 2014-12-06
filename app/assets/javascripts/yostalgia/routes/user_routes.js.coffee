Yostalgia.UserRoute = Yostalgia.Route.extend
  beforeModel: (transition) ->
    # we want to redirect if we are just passed a numerical ID
    user_id = transition.params.user_id
    if !isNaN(user_id)
      @get('store').find('user', user_id).then (user) =>
        @transitionTo 'user', user
  model: (params) ->
    @get('store').find('user', username: params.user_id).then (users) ->
      users.get('firstObject')
  serialize: (model, params) ->
    if model && model.get
      { user_id: model.get('username') }
  setupController: (controller, model) ->
    @_super(controller, model)
    if @session.get('isAuthenticated') && model.get('id') == @session.get('user.id')
      @controllerFor('application').set('currentRoute', 'profile')
    else
      @controllerFor('application').set('currentRoute', '')
  actions:
    showFull: (profile) ->
      @controllerFor('user.full').set('model', profile)
      @send 'openOverlay', 'user.full'
    editProfile: ->
      @session.get('user.profile').then (profile) =>
        if !profile.get('photo')
          profile.set 'photo', @get('store').createRecord('attachment')
        @controllerFor('user.edit').send('edit', profile)
        @send 'openOverlay', 'user.edit'
    changeCoverPhoto: ->
      @controllerFor('coverPhotoSelectorModal').send('reset')
      @send 'openModal', 'coverPhotoSelectorModal'

Yostalgia.UserIndexRoute = Yostalgia.Route.extend
  model: (params) ->
    @modelFor 'user'
  setupController: (controller, model) ->
    @_super(controller, model)
    controller.set('selectedDate', moment().toDate())
    @controllerFor('application').set('previousRouteForPost', 'user')
    @controllerFor('application').set('previousUserForPost', model)

    userId = model.get('id')

    controller.set 'attachments', null
    @get('store').find('attachment', user_id: userId, limit: 10).then (attachments) ->
      controller.set 'attachments', attachments

    controller.set 'events', null
    @get('store').find('event', user_id: userId, limit: 10).then (events) ->
      controller.set 'events', events

Yostalgia.UserFeedRoute = Yostalgia.SecretRoute.extend
  activate: ->
    @controllerFor('application').set 'onUserFeed', true
    @_super.apply(this, arguments)

  beforeModel: ->
    @_super.apply(this, arguments)
    if @session.get('isAuthenticated')
      user = @modelFor 'user'
      @session.get('user').then (currentUser) ->
        if user != currentUser
          friends = currentUser.get('friends').then (friends) ->
            if !friends.contains(user)
              @send 'pushAlert', 'alert', 'Hey!', 'You must be friends with this user to view their feed'
              @transitionTo 'user', user

  setupController: (controller, model) ->
    @_super.apply(this, arguments)
    @controllerFor('application').set 'previousRouteForPost', 'user_feed.posts'
    @controllerFor('application').set 'previousUserForPost', model
    @controllerFor('memoryLane').set 'forUser', @modelFor('user')
    @controllerFor('memoryLane').send 'refresh'

  renderTemplate: ->
    @render()
    @render 'memoryLane',
      into: 'user_feed',
      outlet: 'memoryLane',
      controller: 'memoryLane'

  deactivate: ->
    @controllerFor('application').set 'onUserFeed', false
    @_super.apply(this, arguments)

Yostalgia.UserFeedIndexRoute = Yostalgia.SecretRoute.extend
  activate: ->
    controller = @controllerFor('user_feed.index')
    controller.set 'checkChecked', false
  redirect: ->
    @transitionTo 'user_feed.posts', @modelFor('user'), 'today'

Yostalgia.UserFeedPostsRoute = Yostalgia.SecretRoute.extend
  activate: ->
    controller = @controllerFor('user_feed.posts')
    controller.set 'checkChecked', false
    @controllerFor('application').set 'checkPrivacy', false
  model: (params) ->
    if !params.date or params.date == 'today' or !moment(params.date, 'MM-DD-YYYY').isValid()
      date = moment().startOf('day').toDate()
    else
      date = moment(params.date, 'MM-DD-YYYY').startOf('day').toDate()

    params =
      user_id: @modelFor('user').get('id')
      date: date
      check_private: @controllerFor('application').get('checkPrivacy')

    @store.find('userfeedActivity', params).then (activities) ->
      model = new Ember.Object()
      model.set 'activities', activities
      model.set 'currentDate', date

      prevDate = activities.meta.prev_date
      prevDate = new Date(activities.meta.prev_date) if prevDate != 'none'
      model.set 'prevAvailableDate', prevDate

      nextDate = new Date(activities.meta.next_date)
      if activities.meta.next_date == 'none'
        nextDate = moment().startOf('day').toDate()
      model.set 'nextAvailableDate', nextDate

      return model

  serialize: (model) ->
    date = model.get('currentDate')
    if !date || Yostalgia.Utilities.isToday(date)
      { date: 'today' }
    else
      { date: moment(date).format('MM-DD-YYYY') }

Yostalgia.UserEventCalendarRoute = Yostalgia.SecretRoute.extend
  activate: ->
    @controllerFor('application').set 'onUserFeed', true
    @_super.apply(this, arguments)
  beforeModel: ->
    @_super.apply(this, arguments)
    if @session.get('isAuthenticated')
      user = @modelFor 'user'
      @session.get('user').then (currentUser) =>
        if user != currentUser
          friends = currentUser.get('friends').then (friends) =>
            if !friends.contains(user)
              @send 'pushAlert', 'alert', 'Hey!', 'You must be friends with this user to view their events'
              @transitionTo 'user', user
  model: (params) ->
    if params.date == 'today' or !moment(params.date, 'MM-DD-YYYY').isValid()
      date = moment().startOf('day').toDate()
    else
      date = moment(params.date, 'MM-DD-YYYY').toDate()
    { date: date }
  serialize: (model, params) ->
    date = moment(model.date)
    if moment(date).startOf('day').isSame(moment().startOf('day'))
      { date: 'today' }
    else
      { date: moment(date).format('MM-DD-YYYY') }
  setupController: (controller, model) ->
    controller.set('model', model)
    @controllerFor('application').set('previousRouteForPost', 'user.event_calendar')
    @controllerFor('application').set('previousUserForPost', @modelFor('user'))
    @controllerFor('application').set('previousDateForPost', model.date)
  deactivate: ->
    @controllerFor('application').set 'onUserFeed', false
    @_super.apply(this, arguments)

Yostalgia.UserFriendsRoute = Yostalgia.SecretRoute.extend
  model: (params) ->
    @modelFor('user').get('friends')
  deactivate: ->
    @controllerFor('user.friends').set 'searchTerm', null

Yostalgia.UserPhotosRoute = Yostalgia.SecretRoute.extend
  model: ->
    user = @modelFor 'user'
    if @controllerFor('user.photos').get('loadedForUser') == user
      @controllerFor('user.photos').get('model')
    else
      @get('store').find('attachment', user_id: user.get('id'))
  afterModel: (photos, transition) ->
    user = @modelFor 'user'
    controller = @controllerFor('user.photos')
    if controller.get('loadedForUser') != user
      controller.set 'scrollPosition', 0
    controller.set 'loadedForUser', user
  setupController: (controller, model) ->
    @_super controller, model
    @controllerFor('application').set 'previousRouteForPost', 'user.photos'
    @controllerFor('application').set 'previousUserForPost', @modelFor('user')

Yostalgia.ProfilePhotosRoute = Yostalgia.SecretRoute.extend
  model: ->
    user = @modelFor 'user'
    @get('store').find('attachment', user_id: user.get('id'), profile_photos: true)
  afterModel: (photos, transition) ->
    if transition.targetName != 'profile_photos.photo'
      photo = photos.get('firstObject')
      @transitionTo 'profile_photos.photo', photo
      @controllerFor('profile_photos').send 'selectAttachment', photo
    else
      @_super(arguments)

Yostalgia.ProfilePhotosPhotoRoute = Yostalgia.AttachmentWithCommentsRoute.extend
  model: (params) ->
    @get('store').find('attachment', params.photo_id).then (photo) =>
      @controllerFor('profile_photos').send 'selectAttachment', photo


Yostalgia.CoverPhotosRoute = Yostalgia.SecretRoute.extend
  model: ->
    user = @modelFor 'user'
    @get('store').find('attachment', user_id: user.get('id'), cover_photos: true)
  afterModel: (photos, transition) ->
    if transition.targetName != 'cover_photos.photo'
      photo = photos.get('firstObject')
      @transitionTo 'cover_photos.photo', photo
      @controllerFor('cover_photos').send 'selectAttachment', photo
    else
      @_super(arguments)

Yostalgia.CoverPhotosPhotoRoute = Yostalgia.AttachmentWithCommentsRoute.extend
  model: (params) ->
    @get('store').find('attachment', params.photo_id).then (photo) =>
      @controllerFor('cover_photos').send 'selectAttachment', photo

Yostalgia.UserEventsRoute = Yostalgia.SecretRoute.extend()

Yostalgia.UserProfileVersionRoute = Yostalgia.Route.extend
  serialize: (model, params) ->
    if model
      { date: moment.utc(model.get('timestamp')).format('MM-DD-YYYY') }
  model: (params) ->
    user = @modelFor('user')
    user.get('profile').then (profile) =>
      search_params =
        profile_id: profile.id
        date: moment.utc(params.date, "MM-DD-YYYY").format('YYYY-MM-DD')
      @get('store').find('profileVersion', search_params).then (profile_versions) ->
        return profile_versions.get('firstObject')
  setupController: (controller, model) ->
    @_super(controller, model)
