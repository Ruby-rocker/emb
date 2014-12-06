Yostalgia.PostIndexView = Yostalgia.View.extend

  templateName: (->
    if @get('controller.hasMediaGroup')
      'post/media'
    else
      'post/single'
  ).property('controller.hasMediaGroup')

  _templateChanged: (->
    @rerender()
  ).observes('templateName')

  classNames: ['modal', 'modal-over-nav', 'single-post']
  classNameBindings: ['controller.hasMediaGroup:with-media-group']

  willInsertElement: ->
    @get('controller.attachments').then (attachments) =>
      @get('controller').send('selectAttachment', attachments.get('firstObject'))

  selectedAttachmentChanged: (->
    @get('controller.attachments').then (attachments) =>
      selectedAttachment = @get('controller.selectedAttachment')
      index = attachments.indexOf(selectedAttachment)

      Ember.run.next @, ->
        $nav = $('.media-group .nav')
        if $nav.length
          itemWidth = $nav.find('li').first().width()

          if index + 1 <= 2
            $nav.css('margin-left', 0)
          else if attachments.get('length') - index <= 2
          else
            $nav.css('margin-left', -(index * itemWidth) + itemWidth)
  ).observes('controller.attachments.@each', 'controller.selectedAttachment')
