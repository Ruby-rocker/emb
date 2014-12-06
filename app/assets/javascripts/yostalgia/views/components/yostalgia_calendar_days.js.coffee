Yostalgia.YostalgiaCalendarDaysComponent = Ember.Component.extend

  classNames: ['days']

  headingMonthFormat: 'MMMM'
  headingYearFormat: 'YYYY'

  displayedMonth: Ember.computed.alias('calendar.displayedMonth')
  cells: null
  rows: null

  date: Ember.computed.alias('calendar.date')

  init: ->
    @_super()
    @buildCells() if Ember.isEmpty(@get('cells'))
    @buildRows() if Ember.isEmpty(@get('rows'))
    if !@get('date') && !@get('displayedMonth')
      @set 'displayedMonth', moment().startOf('month')
    if @get('date') && !@get('displayedMonth')
      @set 'displayedMonth', moment(@get('date')).startOf('month')
    @updateCells()

  ### actions ###

  actions:
    gotoPreviousMonth: ->
      displayedMonth = moment @get('displayedMonth')
      @set 'displayedMonth', displayedMonth.subtract(1, 'day').startOf('month')

    gotoNextMonth: ->
      displayedMonth = moment @get('displayedMonth')
      @set 'displayedMonth', displayedMonth.add(1, 'month').startOf('month')

    selectDate: (date) ->
      @changeDate(date)


  ### properties ###

  headingMonth: (->
    @get('displayedMonth').format(@get('headingMonthFormat'))
  ).property('displayedMonth')

  headingYear: (->
    @get('displayedMonth').format(@get('headingYearFormat'))
  ).property('displayedMonth')

  nonEmptyRows: (->
    @get('rows').filter (row) ->
      nonEmptyCells = row.reject (cell) ->
        cell.get('date') == null
      nonEmptyCells.length
  ).property('rows.@each', 'cells.@each.date')


  ### observers ###

  updateCells: (->
    # moment.day() returns 0-6 with 0 as sunday but our index starts on monday
    startingIndex = @get('displayedMonth').day() - 1
    startingIndex = 6 if startingIndex == -1

    daysInMonth = @get('displayedMonth').daysInMonth()

    @get('cells').forEach (cell, index) =>
      if index < startingIndex || index >= startingIndex + daysInMonth
        cell.set('date', null)
        cell.set('content', null)
      else
        date = @get('displayedMonth').clone().add('days', index - startingIndex)
        cell.set('date', date)
        # TODO: add items from events with current date
  ).observes('date', 'displayedMonth')


  ### methods ###

  buildCells: ->
    cells = new Ember.A()
    totalCells = 6 * 7
    for currentCell in [1..totalCells]
      cells.push(new Ember.Object())
    @set('cells', cells)

  buildRows: ->
    rows = new Ember.A
    currentCell = 0
    for currentRow in [1..6]
      row = new Ember.A()
      for i in [0..6]
        row.push(@get('cells')[currentCell])
        currentCell++
      rows.push(row)
    @set('rows', rows)

  changeDate: (date) ->
    @set 'date', date.toDate()



  dayView: Yostalgia.View.extend

    content: null

    classNameBindings: [
      'isEmpty:cal-cell-empty',
      'isDisabled:cal-cell-disabled',
      'isToday:cal-cell-today',
      'hasEvent:cal-cell-with-event',
      'isWeekday:cal-cell-weekday',
      'isSelected:cal-cell-selected'
    ]

    template: Ember.Handlebars.compile(
      '<span class="cal-date">{{view.dateDisplay}}</span>'
    )

    click: ->
      if @get('content.date')
        @get('parentView').changeDate @get('content.date')

    dateDisplay: (->
      @get('content.date').date() if @get('content.date')
    ).property('content.date')

    isEmpty: (->
      @blank 'content.date'
    ).property('content.date')

    isDisabled: (->
      @get 'content.disabled'
    ).property('content.disabled')

    isToday: (->
      if @get('content.date')
        thisDate = @get('content.date').startOf('day')
        today = moment().startOf('day')
        thisDate.isSame(today)
    ).property('content.date')

    isWeekday: (->
      if @get('content.date')
        @get('content.date').day() > 0 && @get('content.date').day() < 6
    ).property('content.date')

    hasEvent: (->
      !@blank 'content.event'
    ).property('content.event')

    isSelected: (->
      if !@blank('content.date') && @get('parentView.date')
        thisDate = @get('content.date').startOf('day')
        selectedDate = moment(@get('parentView.date')).startOf('day')
        thisDate.isSame(selectedDate)
    ).property('content.date', 'parentView.date')
