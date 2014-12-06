Yostalgia.SearchUserView = Yostalgia.View.extend

  tagName: 'li'
  classNames: ['user', 'clearfix']
  templateName: 'search/user'

  user: null

  didInsertElement: ->
    $('.carousel').flexslider
      animation: "slide"
      animationLoop: false
      itemWidth: 210
      maxItems: 2
      controlNav: false
      prevText: "&#xe003;"
      nextText: "&#xe004;"
