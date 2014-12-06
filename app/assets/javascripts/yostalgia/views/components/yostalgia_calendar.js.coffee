Yostalgia.YostalgiaCalendarComponent = Ember.Component.extend

  classNames: ['calendar']

  headingMonthFormat: 'MMMM'
  headingYearFormat: 'YYYY'

  date: null
  events: null

  displayedMonth: null
  showingMonths: false
  showingYears: false

  ### actions ###

  actions:
    gotoToday: ->
      @set 'date', moment().toDate()
      @set 'displayedMonth', moment().startOf('month')
      @send 'showDays'

    showDays: ->
      @set 'showingMonths', false
      @set 'showingYears', false

    showYears: ->
      @set 'showingMonths', false
      @set 'showingYears', true

    showMonths: ->
      @set 'showingYears', false
      @set 'showingMonths', true


  ### properties ###

  showingDays: (->
    !@get('showingMonths') && !@get('showingYears')
  ).property('showingMonths', 'showingYears')
