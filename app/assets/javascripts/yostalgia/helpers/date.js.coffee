Ember.Handlebars.helper 'shortDate', (date) ->
  Yostalgia.Utilities.shortDateDisplay(date)

Ember.Handlebars.helper 'shortTextDate', (date) ->
  Yostalgia.Utilities.shortTextDateDisplay(date)

Ember.Handlebars.helper 'simpleDate', (date) ->
  Yostalgia.Utilities.simpleDateDisplay(date)

Ember.Handlebars.helper 'simpleDateTime', (date) ->
  Yostalgia.Utilities.simpleDateTimeDisplay(date)

Ember.Handlebars.helper 'simpleDateObject', (date) ->
  Yostalgia.Utilities.simpleDateObjectDisplay(date)
