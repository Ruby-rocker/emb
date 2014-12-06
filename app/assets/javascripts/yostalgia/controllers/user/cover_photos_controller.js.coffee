Yostalgia.CoverPhotosController = Yostalgia.ProfilePhotosController.extend

  actions:
    selectAttachment: (attachment) ->
      @clearSelectedAttachments()
      attachment.set('isSelected', true)
      @set 'selectedAttachment', attachment
      @transitionToRoute 'cover_photos.photo', attachment
