Ember.Handlebars.helper 'simple-format', (str) ->

  str = str.replace /\r\n?/, "\n"
  if str.length > 0
    str = str.replace /\n\n+/g, '</p><p>'
    str = str.replace /\n/g, '<br />'
    str = "<p>#{str}</p>"
  return new Handlebars.SafeString str
