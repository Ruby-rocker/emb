Yostalgia.YostalgiaCalendarMonthsComponent = Ember.Component.extend

  classNames: ['months']

  headingYearFormat: 'YYYY'

  year: null
  cells: null
  rows: null

  displayedMonth: Ember.computed.alias('calendar.displayedMonth')
  date: Ember.computed.alias('calendar.date')

  init: ->
    @_super()
    @buildCells() if Ember.isEmpty(@get('cells'))
    @buildRows() if Ember.isEmpty(@get('rows'))
    if @get('date')
      @set 'year', moment(@get('date')).startOf('year')
    else if @get('displayedMonth')
      @set 'year', moment(@get('displayedMonth')).startOf('year')
    else
      @set 'year', moment().startOf('year')


  ### actions ###

  actions:
    gotoPreviousYear: ->
      @set 'year', moment(@get('year')).subtract(1, 'day').startOf('year')

    gotoNextYear: ->
      @set 'year', moment(@get('year')).add(1, 'year').startOf('year')

    selectMonth: (date) ->
      @set 'displayedMonth', date
      @get('calendar').send('showDays')


  ### properties ###

  headingYear: (->
    @get('year').format(@get('headingYearFormat'))
  ).property('year')


  ### observers ###

  updateCells: (->
    @get('cells').forEach (cell, index) =>
      date = @get('year').clone().startOf('year').add('months', index).startOf('month')
      cell.set 'date', date
  ).observes('year').on('init')


  ### methods ###

  buildCells: ->
    cells = new Ember.A()
    for month in [0..11]
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


  monthView: Yostalgia.View.extend

    content: null

    classNameBindings: ['isEmpty:cal-cell-empty', 'isDisabled:cal-cell-disabled', 'isToday:cal-cell-today', 'hasEvent:cal-cell-with-event', 'isSelected:cal-cell-selected']

    render: (buffer) ->
      buffer.push("<span class=\"cal-date\">#{@get('dateDisplay') || ''}</span>")

    click: ->
      if @get('content.date')
        @get('parentView').send('selectMonth', @get('content.date'))

    dateChanged: (->
      @rerender()
    ).observes('content.date')

    dateDisplay: (->
      @get('content.date').format('MMM') if @get('content.date')
    ).property('content.date')

    isEmpty: (->
      @blank 'content.date'
    ).property('content.date')

    isDisabled: (->
      @get 'content.disabled'
    ).property('content.disabled')

    isToday: (->
      if @get('content.date')
        today = @get('content.date').isSame(moment().startOf('month'))
    ).property('content.date')

    hasEvent: (->
      !@blank 'content.event'
    ).property('content.event')

    isSelected: (->
      if !@blank('content.date') && @get('parentView.date')
        moment(@get('content.date')).isSame(moment(@get('parentView.date')).startOf('month'))
    ).property('content.date', 'parentView.date')
