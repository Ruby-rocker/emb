Yostalgia.EventIndexView = Yostalgia.View.extend
  classNames: ['container', 'clearfix', 'event-page']
  templateName: 'event/index'

  coverImageStyle: (->
    attachment = @get 'controller.coverPhoto'
    imageUrl = Yostalgia.Utilities.imageUrl(attachment, width: 960)
    "background-image: url(#{imageUrl});"
  ).property('controller.coverPhoto')
