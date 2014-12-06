Yostalgia.TimeAgoView = Ember.View.extend
  tagName: 'time'

  template: Ember.Handlebars.compile('{{view.output}}')

  output: (->
    moment(@get('value')).fromNow()
  ).property('value')

  didInsertElement: ->
    @tick()

  tick: ->
    nextTick = Ember.run.later @, ->
      @notifyPropertyChange()
      @tick()
    , 1000 * 60
    @set('nextTick', nextTick)

  willDestroyElement: ->
    nextTick = @get('nextTick')
    Ember.run.cancel(nextTick)
