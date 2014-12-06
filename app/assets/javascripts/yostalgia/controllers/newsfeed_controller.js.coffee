Yostalgia.NewsfeedController = Yostalgia.ArrayController.extend

  model: []

  sortProperties: ['postedAt']
  sortAscending: false

  filteredArrangedContent: Ember.computed.uniq 'arrangedContent'

  isLoaded: false
  isLoading: false
  startTime: null
  page: 1
  morePages: false

  displayUserOnFeedItems: true

  actions:
    loadFirstPage: ->
      @set 'isLoaded', false
      @set 'isLoading', true
      @set 'content', []
      @get('store').find('newsfeedActivity', {page: 1}).then (activities) =>
        activities.forEach (activity) =>
          @pushObject(activity) unless @get('model').contains(activity)
        @send 'setMetaData', activities
        @set 'isLoaded', true
        @set 'isLoading', false

    loadNextPage: ->
      return if @get 'isLoading'
      return if !@get 'morePages'

      @set 'isLoading', true
      @get('store').find('newsfeedActivity', {page: @get('page') + 1, start_time: @get('startTime')}).then (activities) =>
        activities.forEach (activity) =>
          @pushObject(activity) unless @get('model').contains(activity)
        @send 'setMetaData', activities
        @set 'isLoading', false

    setMetaData: (activities) ->
      metadata = activities.meta
      @set 'startTime', moment(metadata.start_time).toDate()
      @set 'page', metadata.page
      @set 'morePages', if metadata.more_pages == 'yes' then true else false

