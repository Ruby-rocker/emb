Yostalgia.UserIndexView = Yostalgia.View.extend
  classNames: ['container', 'clearfix']
  classNameBindings: [
    'controller.viewingSelf:own-profile',
    'controller.showFeedLink:with-slide-link'
  ]
  templateName: 'user/index'

  coverPhoto: Ember.computed.alias('controller.profile.coverPhoto')

  coverImageStyle: (->
    if !@blank 'coverPhoto'
      attachment = @get 'coverPhoto'
      imageUrl = Yostalgia.Utilities.imageUrl(attachment, width: 960)
      "background-image: url(#{imageUrl});"
  ).property('coverPhoto')
