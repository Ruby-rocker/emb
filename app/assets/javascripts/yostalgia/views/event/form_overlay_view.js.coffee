Yostalgia.EventFormOverlayView = Yostalgia.OverlayView.extend

  templateName: 'event/form_overlay'

  elementId: 'create-event'
  classNames: ['modal', 'modal-full']

  coverImageStyle: (->
    fpFile = @get 'controller.coverPhotoFile'
    if fpFile
      imageUrl = Yostalgia.Utilities.imageUrl(fpFile, width: 960)
      "background-image: url(#{imageUrl})"
  ).property('controller.coverPhotoFile')
