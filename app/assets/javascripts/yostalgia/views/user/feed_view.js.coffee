Yostalgia.UserFeedView = Yostalgia.View.extend

  classNames: ['container', 'clearfix', 'newsfeed', 'newsfeed-profile']

  templateName: 'user/feed'

  didInsertElement: ->
    $('body').addClass('background-alt')
  willDestroyElement: ->
    $('body').removeClass('background-alt')
