Yostalgia.DatePickerButtonComponent = Ember.Component.extend

  classNames: ['datepicker-button']

  date: null
  calendarVisible: false
  displayedMonth: null

  dateChanged: (->
    @hideCalendar()
  ).observes('date')

  click: (event) ->
    target = $(event.target)
    myId = @$().attr('id')
    if target.attr('id') == myId or !target.parents('.calendar').length
      @toggleCalendar()

  toggleCalendar: ->
    visible = @get 'calendarVisible'
    if visible then @hideCalendar() else @showCalendar()

  hideCalendar: (event) ->
    if event
      unless $(event.target).parents('.calendar').length
        @set 'calendarVisible', false
        @$('.calendar').hide()
        $('body').off 'click.datepickerbutton', $.proxy(@hideCalendar, @)
    else
      @set 'calendarVisible', false
      @$('.calendar').hide()
      $('body').off 'click.datepickerbutton', $.proxy(@hideCalendar, @)

  showCalendar: (event) ->
    if @get 'date'
      @set 'displayedMonth', moment(@get('date')).startOf('month')
    @set 'calendarVisible', true
    @$('.calendar').show()
    $('body').on 'click.datepickerbutton', $.proxy(@hideCalendar, @)
