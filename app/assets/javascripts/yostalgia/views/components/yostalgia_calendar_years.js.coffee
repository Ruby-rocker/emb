Yostalgia.YostalgiaCalendarYearsComponent = Ember.Component.extend

  classNames: ['years']

  headingYearFormat: 'YYYY'

  startYear: null
  cells: null
  rows: null

  displayedMonth: Ember.computed.alias('calendar.displayedMonth')
  date: Ember.computed.alias('calendar.date')

  init: ->
    @_super()
    @buildCells() if Ember.isEmpty(@get('cells'))
    @buildRows() if Ember.isEmpty(@get('rows'))
    if @get('date')
      selectedYear = moment(@get('date')).startOf('year')
    else if @get('displayedMonth')
      selectedYear = moment(@get('displayedMonth')).startOf('year')
    else
      selectedYear = moment().startOf('year')
    @set 'startYear', selectedYear.subtract('years', selectedYear.year() % 10)


  ### actions ###

  actions:
    gotoPreviousYears: ->
      @set 'startYear', moment(@get('startYear')).subtract('years', 10).startOf('year')

    gotoNextYears: ->
      @set 'startYear', moment(@get('startYear')).add('years', 10).startOf('year')

    selectYear: (date) ->
      if @get('date')
        @set 'displayedMonth', moment(@get('date')).year(date.year()).startOf('month')
      else
        @set 'displayedMonth', date.add('months', moment().month()).startOf('month')
      @get('calendar').send('showDays')


  ### properties ###

  headingYear: (->
    "#{@get('startYear').year()} - #{@get('startYear').year() + 9}"
  ).property('startYear')


  ### observers ###

  updateCells: (->
    @get('cells').forEach (cell, index) =>
      if index == 0
        cell.set('date', moment().startOf('year').year(@get('startYear').year() - 1))
      else if index == 11
        cell.set('date', moment().startOf('year').year(@get('startYear').year() + 10))
      else
        cell.set('date', moment().startOf('year').year(@get('startYear').year() + index - 1))
  ).observes('startYear').on('init')


  ### methods ###

  buildCells: ->
    cells = new Ember.A()
    for year in [0..11] # 12 years. 10 + 2 for end years
      cells.push(new Ember.Object())
    @set 'cells', cells

  buildRows: ->
    rows = new Ember.A()
    currentCell = 0
    for currentRow in [0..2]
      row = new Ember.A()
      for rowCell in [0..3]
        row.push(@get('cells')[currentCell])
        currentCell++
      rows.push(row)
    @set('rows', rows)


  yearView: Yostalgia.View.extend

    content: null

    classNameBindings: ['isEmpty:cal-cell-empty', 'isDisabled:cal-cell-disabled', 'isToday:cal-cell-today', 'hasEvent:cal-cell-with-event', 'isSelected:cal-cell-selected']

    render: (buffer) ->
      buffer.push("<span class=\"cal-date\">#{@get('dateDisplay') || ''}</span>")

    click: ->
      if @get('content.date')
        @get('parentView').send 'selectYear', @get('content.date')

    dateChanged: (->
      @rerender()
    ).observes('content.date')

    dateDisplay: (->
      @get('content.date').format('YYYY') if @get('content.date')
    ).property('content.date')

    isEmpty: (->
      @blank 'content.date'
    ).property('content.date')

    isDisabled: (->
      @get 'content.disabled'
    ).property('content.disabled')

    isToday: (->
      if @get('content.date')
        @get('content.date').isSame(moment().startOf('year'))
    ).property('content.date')

    hasEvent: (->
      !@blank 'content.event'
    ).property('content.event')

    isSelected: (->
      if !@blank('content.date') && @get('parentView.date')
        moment(@get('content.date')).isSame(moment(@get('parentView.date')).startOf('year'))
    ).property('content.date', 'parentView.date')

