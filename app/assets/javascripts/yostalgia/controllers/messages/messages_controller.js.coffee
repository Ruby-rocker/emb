Yostalgia.MessagesController = Yostalgia.ArrayController.extend

  sortProperties: ['updatedAt']
  sortAscending: false

  isLoadingLater: false
  isLoadingEarlier: false
  pageSize: 10

  searchQuery: null
  isSearching: false

  earliestDate: null # returned from API in meta

  pageHasFocus: true

  actions:
    loadNew: ->
      return if @get 'isLoadingLater'

      # load all newer if we already have some, otherwise first page
      limit = if @get('currentLatestDate') then 'all' else @get('pageSize')

      if @get 'currentLatestDate'
        timestamp = moment(@get 'currentLatestDate')
          .format(Yostalgia.MS_DATE_FORMAT)
      else
        timestamp = null

      loadOptions =
        timestamp: timestamp
        direction: 'later'
        limit: limit

      @set 'isLoadingLater', true
      @get('store').find('conversation', loadOptions).then (conversations) =>
        @setMeta conversations
        @set 'isLoadingLater', false

    loadEarlierPage: ->
      return if !@get 'canLoadEarlier'

      # load next page of conversations updated before earliestDate
      loadOptions =
        timestamp: moment(@get 'currentEarliestDate').format(Yostalgia.MS_DATE_FORMAT)
        direction: 'earlier'
        limit: @get 'pageSize'

      @set 'isLoadingEarlier', true
      @get('store').find('conversation', loadOptions).then (conversations) =>
        @setMeta conversations
        @set 'isLoadingEarlier', false

    startPollingForNew: ->
      checkNewTimer = @get('checkNewTimer')
      clearInterval checkNewTimer if checkNewTimer
      checkNewTimer = setInterval =>
        @send 'loadNew'
      , @get('loadNewPeriod')
      @set 'checkNewTimer', checkNewTimer

    stopPollingForNew: ->
      checkNewTimer = @get('checkNewTimer')
      clearInterval checkNewTimer if checkNewTimer
      @set 'checkNewTimer', null

    startInactivityTimer: ->
      inactivityTimer = @get('inactivityTimer')
      Ember.run.cancel inactivityTimer if inactivityTimer
      inactivityTimer = Ember.run.later @, ->
        @send('stopPollingForNew')
      , 10 * 60 * 1000
      @set 'inactivityTimer', inactivityTimer

    stopInactivityTimer: ->
      inactivityTimer = @get('inactivityTimer')
      Ember.run.cancel inactivityTimer if inactivityTimer
      @set 'inactivityTimer', null

    focusIn: ->
      @set 'pageHasFocus', true
      @send 'loadNew'
      @send 'startPollingForNew'
      @send 'stopInactivityTimer'

    focusOut: ->
      @set 'pageHasFocus', false
      @send 'startPollingForNew'
      @send 'startInactivityTimer' # using start as it changes interval

  loadNewPeriod: (->
    if @get 'pageHasFocus'
      15 * 1000
    else
      60 * 1000
  ).property('pageHasFocus')

  currentEarliestDate: (->
    @get 'arrangedContent.lastObject.updatedAt'
  ).property('arrangedContent.@each.updatedAt')

  canLoadEarlier: (->
    currentEarliestTime = @get('currentEarliestDate').getTime()
    earliestTime = @get('earliestDate').getTime()
    !@get('isLoadingEarlier') && currentEarliestTime != earliestTime
  ).property('isLoadingEarlier', 'earliestDate', 'currentEarliestDate')

  currentLatestDate: (->
    @get 'arrangedContent.firstObject.updatedAt'
  ).property('arrangedContent.@each.updatedAt')

  setMeta: (conversations) ->
    @set 'earliestDate', new Date(conversations.meta.earliest_date)

  searchQueryChanged: (->
    searchQuery = @get 'searchQuery'
    if Ember.isEmpty searchQuery
      @set 'model', @get('store').filter 'conversation'
    else
      @set 'isSearching', true
      @get('store').find('conversation', search: searchQuery).then (conversations) =>
        @set 'model', conversations
        @set 'isSearching', false
  ).observes('searchQuery')
