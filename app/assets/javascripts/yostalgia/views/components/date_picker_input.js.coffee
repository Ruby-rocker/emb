Yostalgia.DatePickerInputComponent = Ember.Component.extend

  classNames: ['datepicker-input']

  date: null
  calendarVisible: false
  displayedMonth: null
  format: 'MM/DD/YYYY'
  placeholder: null

  formattedDate: ((key, value) ->
    if arguments.length == 2
      if value
        if moment(value).isValid()
          @set 'date', moment(value).toDate()
        else
          @set 'date', null
      else
        @set 'date', null

    else if arguments.length == 1 && @get('date')
      moment(@get('date')).format(@get('format'))
  ).property('date')

  dateChanged: (->
    # prevents swallowed first click bug as seen on new-event overlay
    @set('date', null) if @get('date') == undefined

    if !Ember.isEmpty @get('date')
      @hideCalendar()
  ).observes('date').on('init')

  handleHideEvent: (event) ->
    unless $.contains(@$().context, event.target)
      @hideCalendar()

  hideCalendar: ->
    @set 'calendarVisible', false
    @$('.calendar').hide() if @$('.calendar')
    $('body').off 'click.datepickerinput', $.proxy(@handleHideEvent, @)
    $('body').off 'focusIn.datepickerinput', $.proxy(@handleHideEvent, @)

  showCalendar: ->
    if @get 'date'
      @set 'displayedMonth', moment(@get('date')).startOf('month')
    @set 'calendarVisible', true
    @$('.calendar').show()
    $('body').on 'click.datepickerinput', $.proxy(@handleHideEvent, @)
    $('body').on 'focusIn.datepickerinput', $.proxy(@handleHideEvent, @)


  textInput: Ember.TextField.extend

    valueBinding: 'parentView.formattedDate'

    focusIn: ->
      @get('parentView').showCalendar()
