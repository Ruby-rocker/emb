Ember.Handlebars.helper 'pluralize', (singular, count) ->
  if parseInt(count) == 1
    singular
  else
    Ember.Inflector.inflector.pluralize(singular)
