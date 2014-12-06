# adapted from http://loopj.com/jquery-tokeninput/
# rewritten to work directly with ember objects and offload searching to
# external methods

KEY =
  BACKSPACE: 8
  TAB: 9
  ENTER: 13
  ESCAPE: 27
  SPACE: 32
  PAGE_UP: 33
  PAGE_DOWN: 34
  END: 35
  HOME: 36
  LEFT: 37
  UP: 38
  RIGHT: 39
  DOWN: 40
  NUMPAD_ENTER: 108
  COMMA: 188


Yostalgia.TokenInputComponent = Ember.Component.extend

  classNames: ['token-input']

  ### external attributes/bindings ###

  selected: null
  searchMethod: null
  searchResults: null

  tokenProperty: 'name'
  resultProperty: 'name'

  hintText: 'Type to search...'
  noResultsText: 'Sorry, no matches were found'
  searchingText: 'Searching...'

  searchDelay: 150
  tokenLimit: null
  preventDuplicates: true

  ### internal attributes ###

  # keep internal list of tokens/results to decorate with additional properties
  tokens: Ember.A()
  results: Ember.A()

  searchTerm: null
  isSearching: false


  ### actions ###

  actions:
    addToken: (result) ->
      @get('selected').pushObject result.get('content')
      @send 'reset'
      @send 'focus'

    addSelectedResult: ->
      unless Ember.isEmpty @get('selectedResult')
        @send 'addToken', @get('selectedResult')

    deleteToken: (token) ->
      @get('selected').removeObject token.get('content')
      @send 'reset'

    deleteLastToken: ->
      unless Ember.isEmpty(@get 'tokens')
        @send 'deleteToken', @get('tokens')[@get('tokens.length')-1]

    selectResult: (result) ->
      if result
        @get('results').forEach (result) ->
          result.set 'isSelected', false
        result.set 'isSelected', true

    selectNextResult: ->
      results = @get 'results'
      selectedResult = @get 'selectedResult'
      unless Ember.isEmpty results
        currentIndex = results.indexOf(@get('selectedResult'))
        if currentIndex+1 < results.get('length')
          newResult = results[currentIndex + 1]
          @send 'selectResult', newResult

    selectPreviousResult: ->
      results = @get 'results'
      selectedResult = @get 'selectedResult'
      unless Ember.isEmpty results
        currentIndex = results.indexOf(@get('selectedResult'))
        if currentIndex-1 >= 0
          newResult = results[currentIndex - 1]
          @send 'selectResult', newResult

    focus: ->
      @$('input').focus()

    reset: ->
      @set 'searchTerm', null
      @set 'results', Ember.A()


  ### properties ###

  message: (->
    return @get 'searchingText' if @get 'isSearching'
    if @get 'hasFocus'
      return @get 'hintText' if Ember.isEmpty @get('searchTerm')
      return @get 'noResultsText' if !@get 'results.length'
    null
  ).property('isSearching', 'results.length', 'searchTerm', 'hasFocus')

  showDropdown: (->
    @get('hasFocus') && (@get('message') || !Ember.isEmpty(@get('results')))
  ).property('hasFocus', 'message', 'results')

  selectedResult: (->
    @get('results').filterBy('isSelected')[0]
  ).property('results.@each.isSelected')

  ### observers ###

  updateTokensFromSelected: (->
    tokens = @get('tokens')
    selected = @get('selected')

    # remove tokens without matches
    tokens = tokens.reject (token) ->
      !selected.contains token.get('content')

    # add new matches
    contents = tokens.mapBy 'content'
    selected.forEach (selected) ->
      unless contents.contains selected
        token = new Ember.Object
        token.set 'content', selected
        tokens.pushObject token

    @set 'tokens', tokens
  ).observes('selected.@each').on('init')

  searchTermChanged: (->
    @set 'results', Ember.A()
    if !Ember.isEmpty @get('searchTerm')
      @set 'isSearching', true
      Ember.run.debounce @, @getSearchResults, @get('searchDelay')
    else
      @set 'isSearching', false
  ).observes('searchTerm')

  getSearchResults: ->
    @set 'isSearching', true
    @sendAction 'searchMethod', @get('searchTerm')

  updateResultsFromSearchResults: (->
    results = Ember.A()
    searchResults = @get 'searchResults'

    if @get 'preventDuplicates'
      selected = @get 'selected'
      searchResults = searchResults.reject (searchResult) ->
        selected.contains searchResult

    searchResults.forEach (searchResult, index) ->
      result = new Ember.Object
      result.set 'content', searchResult
      result.set 'isSelected', true if index == 0
      results.pushObject result

    @set 'results', results
    @set 'isSearching', false
  ).observes('searchResults.@each', 'selected.@each', 'preventDuplicates')



Yostalgia.TokenInputInputComponent = Ember.TextField.extend
  classNames: ['token-input__new-token__field']

  keyDown: (event) ->
    parentView = @get('parentView')
    switch event.keyCode
      when KEY.UP
        event.preventDefault()
        parentView.send 'selectPreviousResult'
      when KEY.DOWN
        event.preventDefault()
        parentView.send 'selectNextResult'
      when KEY.TAB, KEY.ENTER, KEY.NUMPAD_ENTER, KEY.COMMA
        event.preventDefault()
        parentView.send 'addSelectedResult'
      when KEY.BACKSPACE
        if Ember.isEmpty(@get 'value')
          event.preventDefault()
          parentView.send 'deleteLastToken'
      when KEY.ESCAPE
        event.preventDefault()
        @$().blur()

  focusIn: (event) ->
    @get('parentView').set 'hasFocus', true

  focusOut: (event) ->
    @get('parentView').send 'reset'
    @get('parentView').set 'hasFocus', false


Yostalgia.TokenInputTokenComponent = Ember.Component.extend
  tagName: 'li'
  classNameBindings: [
    ':token-input__token',
    'token.isSelected:token-input__token--selected'
  ]

  token: null

  actions:
    deleteToken: ->
      @get('parentView').send 'deleteToken', @get('token')

  # we need to dynamicaly define the property as we don't know the dependent
  # key until runtime
  textProperty: (->
    tokenProperty = @get('parentView.tokenProperty')

    Ember.defineProperty @, 'text', Ember.computed(->
      if content = @get 'token.content'
        content.get tokenProperty
    ).property("token.content.#{tokenProperty}")

  ).observes('parentView.tokenProperty').on('init')

Yostalgia.TokenInputResultComponent = Ember.Component.extend
  tagName: 'li'
  classNameBindings: [
    ':token-input__dropdown__result',
    'result.isSelected:token-input__dropdown__result--selected',
  ]

  result: null

  # using mouseDown/mouseUp here as the focusOut event on the input fires before
  # 'click' and clears our list and prevents our own events from firing
  mouseDown: (event) ->
    event.preventDefault()

  mouseUp: (event) ->
    event.preventDefault()
    @get('parentView').send 'addToken', @get('result')

  mouseEnter: (event) ->
    @get('parentView').send 'selectResult', @get('result')

  # we need to dynamicaly define the property as we don't know the dependent
  # key until runtime
  textProperty: (->
    resultProperty = @get('parentView.resultProperty')

    Ember.defineProperty @, 'text', Ember.computed(->
      if text = @get('result.content').get resultProperty
        openingTag = '<em class="token-input__dropdown__result__match">'
        closingTag = '</em>'
        searchTerm = @get('parentView.searchTerm')
        regex = new RegExp "(#{searchTerm})", 'gi'
        text.replace regex, "#{openingTag}$1#{closingTag}"
    ).property("result.content.#{resultProperty}")

  ).observes('parentView.resultProperty').on('init')
