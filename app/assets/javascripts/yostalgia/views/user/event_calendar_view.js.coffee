Yostalgia.UserEventCalendarView = Yostalgia.View.extend
  classNames: ['container', 'clearfix', 'newsfeed', 'newsfeed-profile', 'event-calandar']

  didInsertElement: ->
    $('body').addClass('background-alt')
    Ember.run.scheduleOnce 'afterRender', @, ->
      $('#posts').masonry
        itemSelector: '.post'

  willDestroyElement: ->
    $('body').removeClass('background-alt')
