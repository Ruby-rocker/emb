Yostalgia.ConversationIndexController = Yostalgia.ArrayController.extend

  # NB: When searching it's possible to load a message list in the middle of a
  # conversation so we need to handle infinite-scrolling in both directions
  #
  # I'm assuming that we always have a contiguous block of loaded messages
  # in the store

  needs: ['conversation']

  sortProperties: ['createdAt']
  sortAscending: true

  pageSize: 10

  isLoadingEarlier: false
  isLoadingLater: false

  loadNewPeriod: 5 * 1000

  actions:
    loadNew: ->
      # TODO: when we load a conversation from the middle of the message stream
      # (from searching for example) we don't want to load new messages
      # immediately, we should wait until the user has viewed the final page

      # if we don't have any messages yet, load the latest messages
      # otherwise load any new messages since our last loaded message
      limit = if !Ember.isEmpty(@get('model')) then 'all' else @get('pageSize')

      if @get 'currentLatestDate'
        timestamp = moment(@get 'currentLatestDate')
          .format(Yostalgia.MS_DATE_FORMAT)
      else
        timestamp = null

      loadOptions =
        conversation_id: @get 'conversation.id'
        timestamp: timestamp
        limit: limit

      @store.find 'message', loadOptions

    loadEarlierPage: ->
      if @get('canLoadEarlier') && !@get('isLoadingEarlier')
        @set 'isLoadingEarlier', true

        timestamp = moment(@get 'currentEarliestDate')
          .format(Yostalgia.MS_DATE_FORMAT)

        loadOptions =
          conversation_id: @get 'conversation.id'
          timestamp: timestamp
          direction: 'earlier'
          limit: @get 'pageSize'

        @store.find('message', loadOptions).then =>
          @set 'isLoadingEarlier', false


    loadLaterPage: ->
      if @get('canLoadLater') && !@get('isLoadingLater')
        @set 'isLoadingLater', true

        timestamp = moment(@get 'currentLatestDate')
          .format(Yostalgia.MS_DATE_FORMAT)

        loadOptions =
          conversation_id: @get 'conversation.id'
          timestamp: timestamp
          direction: 'later'
          limit: @get 'pageSize'

        @store.find('message', loadOptions).then =>
          @set 'isLoadingLater', false
          if !@get 'canLoadLater'
            @send 'markConversationAsRead'


  conversation: Ember.computed.alias 'controllers.conversation'

  earliestDate: Ember.computed.alias 'conversation.createdAt'

  currentEarliestDate: (->
    @get 'arrangedContent.firstObject.createdAt'
  ).property('arrangedContent.@each')

  canLoadEarlier: (->
    @get('earliestDate') < @get('currentEarliestDate')
  ).property('earliestDate', 'currentEarliestDate')

  latestDate: Ember.computed.alias 'conversation.updatedAt'

  currentLatestDate: (->
    @get 'arrangedContent.lastObject.createdAt'
  ).property('arrangedContent.@each')

  canLoadLater: (->
    @get('latestDate') > @get('currentLatestDate')
  ).property('latestDate', 'currentLatestDate')
