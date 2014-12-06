Yostalgia.MentionsTextView = Ember.ContainerView.extend

  text: null
  simpleFormat: false

  textChanged: (->
    if text = @get 'text'
      mentions = text.match /@\[([^\]]+)\]\((\w+):(\d+)\)/g
      template = ''

      if @get 'simpleFormat'
        text = text.replace /\r\n?/, "\n"
        if text.length > 0
          text = text.replace /\n\n+/g, '</p><p>'
          text = text.replace /\n/g, '<br />'
          text = "<p>#{text}</p>"

      if !Ember.isEmpty mentions
        mentions.forEach (mention, index) =>
          # add any plain text before mention
          prefix = text.slice 0, text.indexOf(mention)
          if prefix != ''
            template += prefix
            text = text.slice prefix.length, text.length

          parts = mention.match /@\[([^\]]+)\]\((\w+):(\d+)\)/
          template += "{{#link-to 'user' #{parts[3]}}}#{parts[1]}{{/link-to}}"
          text = text.slice mention.length, text.length

        template += text
      else
        template = text

      @removeAllChildren()
      @pushObject @templateView(template)
  ).observes('text').on('init')

  templateView: (template) ->
    Ember.View.create
      tagName: 'div'
      template: Ember.Handlebars.compile(template)
