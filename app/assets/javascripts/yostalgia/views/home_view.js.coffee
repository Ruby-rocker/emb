Yostalgia.HomeView = Ember.View.extend

  didInsertElement: ->
    $('body').addClass('loading')

    $('.flexslider').flexslider
      animation: "fade"
      slideshow: false
      controlNav: false
      keyboard: true
      touch: true
      animationSpeed: 500
      directionNav: true
      prevText: "&#xe003;"
      nextText: "&#xe004;"
      start: (slider) ->
        $('body').removeClass('loading')

