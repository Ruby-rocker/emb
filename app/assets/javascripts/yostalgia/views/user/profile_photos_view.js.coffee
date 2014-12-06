Yostalgia.ProfilePhotosView = Yostalgia.View.extend

  templateName: 'user/profile_photos'

  classNames: ['modal', 'modal-over-nav', 'single-post', 'with-media-group']

  selectedAttachmentChanged: (->
    attachments = @get('controller.model')
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
  ).observes('controller.model.@each', 'controller.selectedAttachment')
