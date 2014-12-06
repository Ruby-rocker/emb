Yostalgia.UserEventCalendarController = Yostalgia.ObjectController.extend

  needs: ['user']
  date_status: false

  user: Ember.computed.alias('controllers.user.model')
  viewingSelf: Ember.computed.alias('controllers.user.viewingSelf')

  newDate: null

  ### actions ###

  actions:
    gotoPrevDate: ->
      @set 'date_status', false
      @transitionToRoute 'user.event_calendar', {date: @get('prevAvailableDate'), date_status: false }

    gotoNextDate: ->
      @set 'date_status', false
      @transitionToRoute 'user.event_calendar', {date: @get('nextAvailableDate'), date_status: false }

    gotoCurrentMonth: -> 
      @set 'date_status', false
      @transitionToRoute 'user.event_calendar', {date: @get('date'), date_status: false }
  ### properties ###

  selectedDateDisplay: (->
    if @blank 'date'
      @set 'date', moment().startOf('day').toDate()

    Yostalgia.Utilities.simpleMonthDisplay(@get('date'))
  ).property('date')

  activities: (->
    @get('store').find('event', { user_id: @get('user.id'), date: @get('date'), date_status: @get('date_status') })
  ).property('date')

  isLoaded: (->
    @get('activities.content.isLoaded')
  ).property('activities.content.isLoaded')

  emptyFeedText: (->
    firstName = @get('user.profile.firstName')
    if @get('selectedDateDisplay') == 'Today'
      "#{firstName} hasn't posted anything yet today"
    else if @get('date') < new Date()
      "Looks like #{firstName} had an uneventful day, nothing to see here!"
    else
      "#{firstName} doesn't have anything planned yet for #{@get('selectedDateDisplay').toLowerCase()}"
  ).property('user.profile.firstName', 'date')

  nextAvailableDate: (->
    nextDate = @get('activities.content.meta.next_date')
    nextDate = moment().startOf('day').toDate() if nextDate == 'none'
    return nextDate
  ).property('activities.content.meta')

  prevAvailableDate: (->
    @get 'activities.content.meta.prev_date'
  ).property('activities.content.meta')

  allEventsTimes: (->
    @get 'activities.content.meta.event_times'
  ).property('activities.content.meta')

  displayUser: (->
    !@get('isUserFeed')
  ).property()

  nextNavDisabled: (->
    isToday = moment(@get('date')).isSame(moment().startOf('day').toDate())
    isToday || !@get('activities.content.isLoaded') || !moment(@get('nextAvailableDate')).isValid()
  ).property('activities.content.isLoaded', 'nextAvailableDate')

  prevNavDisabled: (->
    !@get('activities.content.isLoaded') || !moment(@get('prevAvailableDate')).isValid()
  ).property('activities.content.isLoaded', 'prevAvailableDate')

  ### observers ###

  changeDate: (->
    @set 'date_status', true
    @transitionToRoute 'user.event_calendar', {date: @get('newDate')}
  ).observes('newDate')
