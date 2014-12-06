###
  Mentions Input

  Inspired by jQuery.mentionsInput, expanded to match Facebook's
  mention input functionality

  Raw tag format: "@[{display text}]({object type}:{object id})"
  Example: "I'm tagging @[Kevin Ansfield](User:1) in a message"
###

KEY =
  BACKSPACE: 8
  DELETE: 46
  TAB: 9
  ENTER: 13
  ESCAPE: 27
  END: 35
  HOME: 36
  LEFT: 37
  UP: 38
  RIGHT: 39
  DOWN: 40

WRAPPER_STYLES = [
  "letterSpacing",
  "fontSize",
  "fontFamily",
  "fontStyle",
  "fontWeight",
  "lineHeight",
  "borderTopWidth",
  "borderRightWidth",
  "borderBottomWidth",
  "borderLeftWidth",
  "borderTopStyle",
  "borderRightStyle",
  "borderBottomStyle",
  "borderLeftStyle",
  "borderTopColor",
  "borderRightColor",
  "borderBottomColor",
  "borderLeftColor",
  "borderRadius",
  "background-color"
]

OVERLAY_STYLES = [
  "display",
  "paddingTop",
  "paddingRight",
  "paddingBottom",
  "paddingLeft",
  "overflow",
  "letterSpacing",
  "fontSize",
  "fontFamily",
  "fontStyle",
  "fontWeight",
  "lineHeight",
  "boxSizing",
  "text-shadow"
]


### util methods ###

copyStyles = (styles, $from, $to) ->
  $.each styles, (i, style) ->
    $to.css style, $from.css(style)


Yostalgia.MentionsInputMention = Ember.Object.extend
  text: null
  user: null

  value: (->
    "@[#{@get('text')}](User:#{@get('user.id')})"
  ).property('text', 'user')


### main component ###

Yostalgia.MentionsInputComponent = Ember.Component.extend

  classNameBindings: [
    ':mentions-input',
    'isPositionedTop:mentions-input--top'
  ]

  ### external attributes/bindings ###

  value: null
  placeholder: null
  searchMethod: null
  searchResults: null

  triggerChar: '@'
  dropdownPosition: 'bottom'

  searchDelay: 150
  preventDuplicates: true

  ### internal attributes ###

  inputValue: ''
  previousInputValue: ''
  mentions: null
  mentionsSorting: ['charPos']
  sortedMentions: Ember.computed.sort 'mentions', 'mentionsSorting'
  autoCompleteItems: null
  selectedAutoCompleteItem: null

  searchTerm: null
  isSearching: false

  init: ->
    @_super.apply(this, arguments)
    @set 'mentions', Ember.A()
    @set 'autoCompleteItems', Ember.A()


  ### actions ###

  actions:
    addMention: (autoCompleteItem) ->
      inputValue = @get('inputValue')
      cursor = Cursores.startsWith @get('triggerChar')
      token = @currentToken()
      tokenStartPos = @caretPos() - token.prefix.length

      mention = @mentionFromUser autoCompleteItem.get('content')
      mention.set 'charPos', tokenStartPos
      @get('mentions').pushObject mention

      newCaretPos = tokenStartPos + mention.get('text.length')
      # caret position updates after 'inputValueUpdated' fires so we cache the
      # position for use in the mention position updates
      @set 'newCaretPos', newCaretPos

      inputValue = cursor.replace inputValue, @caretPos(), mention.get('text')
      @set 'inputValue', inputValue
      @$('textarea').caret newCaretPos


    addSelectedAutoCompleteItem: ->
      unless Ember.isEmpty @get('selectedAutoCompleteItem')
        @send 'addMention', @get('selectedAutoCompleteItem')

    deleteMention: (mention) ->
      mentions = @get('mentions').without mention
      @set 'mentions', mentions

    hideAutoComplete: ->
      @set 'showAutoCompleteList', false
      @set 'autoCompleteItems', Ember.A()

    selectAutoCompleteItem: (autoCompleteItem) ->
      if autoCompleteItem
        @get('autoCompleteItems').forEach (item) ->
          item.set 'isSelected', false
        autoCompleteItem.set 'isSelected', true

    selectPreviousAutoCompleteItem: ->
      if !Ember.isEmpty @get('autoCompleteItems')
        autoCompleteItems = @get 'autoCompleteItems'
        selectedAutoCompleteItem = @get 'selectedAutoCompleteItem'
        currentIndex = autoCompleteItems.indexOf selectedAutoCompleteItem
        if currentIndex-1 >= 0
          newAutoCompleteItem = autoCompleteItems[currentIndex - 1]
        else
          newAutoCompleteItem = autoCompleteItems[autoCompleteItems.length - 1]
        @send 'selectAutoCompleteItem', newAutoCompleteItem

    selectNextAutoCompleteItem: ->
      if !Ember.isEmpty @get('autoCompleteItems')
        autoCompleteItems = @get 'autoCompleteItems'
        selectedAutoCompleteItem = @get 'selectedAutoCompleteItem'
        currentIndex = autoCompleteItems.indexOf selectedAutoCompleteItem
        if currentIndex+1 < autoCompleteItems.get('length')
          newAutoCompleteItem = autoCompleteItems[currentIndex + 1]
        else
          newAutoCompleteItem = autoCompleteItems[0]
        @send 'selectAutoCompleteItem', newAutoCompleteItem


  ### properties ###

  overlayContent: (->
    overlayContent = @get 'value'
    return null if Ember.isEmpty(overlayContent)

    if !Ember.isEmpty overlayContent
      if mentions = overlayContent.match /@\[([^\]]+)\]\((\w+):(\d+)\)/g
        mentions.forEach (mention) ->
          parts = mention.match /@\[([^\]]+)\]\((\w+):(\d+)\)/
          text = "<span>#{parts[1]}</span>"
          overlayContent = overlayContent.replace mention, text

      overlayContent.replace "\n", "<br>"

    return new Handlebars.SafeString overlayContent
  ).property('value')

  selectedAutoCompleteItem: (->
    @get('autoCompleteItems').filterBy('isSelected')[0]
  ).property('autoCompleteItems.@each.isSelected')

  autoCompleteIsVisible: (->
    @get('showAutoCompleteList') && @get('autoCompleteItems.length') > 0
  ).property('autoCompleteItems.length', 'showAutoCompleteList')

  isPositionedTop: (->
    @get('dropdownPosition') == 'top'
  ).property('dropdownPosition')


  ### observers ###

  valueUpdated: (->
    value = @get 'value'
    @populateFromValue(value) if value != @valueFromInputValue()
  ).observes('value').on('init')

  inputValueUpdated: (->
    @updateMentions()
    @updateSearchTerm()

    @set 'previousInputValue', @get('inputValue')
    @set 'value', @valueFromInputValue()
  ).observes('inputValue')

  updateMentions: ->
    oldValue = @get 'previousInputValue'
    newValue = @get 'inputValue'
    difference = newValue.length - oldValue.length

    affectedMentions = @get('mentions').filter (mention) =>
      caretPos = @get('newCaretPos') || @caretPos()
      mention.get('charPos') >= caretPos - difference

    affectedMentions.forEach (mention) ->
      mention.set 'charPos', mention.get('charPos') + difference

    @set 'newCaretPos', null

  updateSearchTerm: ->
    @set 'searchTerm', ''
    @set 'showAutoCompleteList', false
    token = @currentToken()
    if token?.value
      searchValue = token.value.slice 1, token.value.length
      @set 'searchTerm', searchValue
      @set 'showAutoCompleteList', true

  searchTermChanged: (->
    @set 'autoCompleteItems', Ember.A()
    if !Ember.isEmpty @get('searchTerm')
      @set 'isSearching', true
      Ember.run.debounce @, @getAutoCompleteResults, @get('searchDelay')
    else
      @set 'isSearching', false
  ).observes('searchTerm')

  getAutoCompleteResults: ->
    @set 'isSearching', true
    @sendAction 'searchMethod', @get('searchTerm')

  updateAutoCompleteItemsFromSearchResults: (->
    autoCompleteItems = Ember.A()
    searchResults = @get 'searchResults'

    if @get 'preventDuplicates'
      mentionedUsers = @get('mentions').mapBy('user')
      searchResults = searchResults.reject (searchResult) ->
        mentionedUsers.contains searchResult

    searchResults.forEach (searchResult, index) ->
      autoCompleteItem = new Ember.Object
      autoCompleteItem.set 'content', searchResult
      autoCompleteItem.set 'isSelected', true if index == 0
      autoCompleteItems.pushObject autoCompleteItem

    if @get('dropdownPosition') == 'top'
      autoCompleteItems.reverse()

    @set 'autoCompleteItems', autoCompleteItems
    @set 'isSearching', false
  ).observes('searchResults.@each', 'selected.@each', 'preventDuplicates')

  valueFromInputValue: ->
    # take inputValue and mentions collection and format into value
    newValue = @get 'inputValue'
    mentions = @get 'sortedMentions'
    charPosOffset = 0

    mentions.forEach (mention) ->
      charPos = charPosOffset + mention.get('charPos')
      text = newValue.slice(charPos, charPos + mention.get('text').length)
      if mention.get('text') == text
        start = newValue.slice(0, charPos)
        end = newValue.slice(charPos + mention.get('text').length, newValue.length)
        mentionText = mention.get('value')
        newValue = start + mentionText + end
        charPosOffset += mentionText.length - mention.get('text').length

    return newValue

  populateFromValue: (value) ->
    inputValue = value
    mentions = @get('mentions')

    if Ember.isEmpty value
      @set 'mentions', Ember.A()
      inputValue = ''

    else if mentionValues = value.match /@\[([^\]]+)\]\((\w+):(\d+)\)/g
      mentionValues.forEach (mentionValue) ->
        parts = mentionValue.match /@\[([^\]]+)\]\((\w+):(\d+)\)/
        mention = new Yostalgia.MentionsInputMention
        user = new Ember.Object
        user.set 'id', parts[3]
        mention.set 'user', user
        mention.set 'text', parts[1]
        mention.set 'charPos', inputValue.indexOf(parts[0])
        mentions.pushObject mention
        inputValue = inputValue.replace parts[0], parts[1]

    @set 'inputValue', inputValue


  mentionFromUser: (user) ->
    mention = new Yostalgia.MentionsInputMention
    mention.set 'user', user
    mention.set 'text', user.get('profile.fullName')
    return mention

  currentToken: ->
    if @caretPos()
      cursor = Cursores.startsWith @get('triggerChar')
      cursor.token @get('inputValue'), @caretPos()

  caretPos: ->
    if @$('textarea')
      @$('textarea').caret()


### text area component ###

Yostalgia.MentionsInputTextareaComponent = Yostalgia.AutosizeTextareaComponent.extend

  value: Ember.computed.alias 'parentView.inputValue'
  mentions: Ember.computed.alias 'parentView.mentions'

  placeholder: Ember.computed.alias 'parentView.placeholder'

  classNames: ['mentions-input__textarea']

  didInsertElement: ->
    @_super.apply this, arguments
    container = @$().parent('.mentions-input')
    copyStyles WRAPPER_STYLES, @$(), container
    copyStyles OVERLAY_STYLES, @$(), container.find('.mentions-input__overlay')
    container.css 'width', '100%'
    container.find('.mentions-input__overlay').css 'width', '100%'
    @$().css
      width: '100%'
      border: 'none'
      position: 'relative'
      resize: 'none'
      margin: 0
      'background-color': 'transparent'

  willDestroyElement: ->
    @_super.apply this, arguments

  keyDown: (e) ->
    if e.keyCode == KEY.BACKSPACE || e.keyCode == KEY.DELETE
      @delete e
      return true

    switch e.keyCode
      when KEY.UP
        if @get('parentView.autoCompleteIsVisible')
          @get('parentView').send 'selectPreviousAutoCompleteItem'
          return false
      when KEY.DOWN
        if @get('parentView.autoCompleteIsVisible')
          @get('parentView').send 'selectNextAutoCompleteItem'
          return false
      when KEY.TAB, KEY.ENTER, KEY.NUMPAD_ENTER, KEY.COMMA
        if @get('parentView.autoCompleteIsVisible')
          @get('parentView').send 'addSelectedAutoCompleteItem'
          @get('parentView').send 'hideAutoComplete'
          return false
      when KEY.ESCAPE
        @get('parentView').send 'hideAutoComplete'
        return false

    return true

  focusOut: (e) ->
    @get('parentView').send 'hideAutoComplete'

  delete: (e) ->
    range = @$().range()
    caretPos = @$().caret()
    cursor = new Cursores()
    token = cursor.token @$()[0]
    mentions = @get('mentions')

    mentions.forEach (mention) =>
      startPos = mention.get('charPos')
      endPos = startPos + mention.get('text').length

      if range.length != 0
        if endPos > range.start && startPos < range.end
          mentions.removeObject mention

      else
        if range.start >= startPos && range.end <= endPos
          mentionText = mention.get 'text'
          mentionText = mentionText.replace(token.value, '').trim()
          mentionText = mentionText.replace /\s{2,}/g, ' '
          mention.set 'text', mentionText
          if Ember.isEmpty mention.get('text')
            mentions.removeObject mention

          cursor.replace @$()[0], ''


### autocomplete item component ###

Yostalgia.MentionsInputAutoCompleteItemComponent = Ember.Component.extend
  tagName: 'li'
  classNameBindings: [
    ':mentions-input__autocomplete__item',
    'item.isSelected:mentions-input__autocomplete__item--selected'
  ]

  item: null

  mouseDown: (e) ->
    e.preventDefault()

  mouseUp: (e) ->
    e.preventDefault()
    @get('parentView').send 'addMention', @get('item')

  mouseEnter: (e) ->
    @get('parentView').send 'selectAutoCompleteItem', @get('item')
