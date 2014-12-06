//= require jquery
//= require jquery_ujs

// Marketing Javascript
//= require jquery.fittext
//= require jquery.flexslider
//= require breakpoint

// App Javascript

//= require env

//= require handlebars
//= require ember
//= require ember-states
//= require ember-data
//= require ember-simple-auth
//= require ember-simple-auth-devise

//= require bootstrap/dropdown
//= require moment
//= require chrono.min
//= require jquery.masonry
//= require jquery.autosize
//= require jquery.caret
//= require cursores

//= require_self

//= require ./yostalgia/store

// Stuff that needs loading first
//= require_tree ./yostalgia/initializers
//= require_tree ./yostalgia/mixins
//= require ./yostalgia/views/_base
//= require ./yostalgia/views/_overlay
//= require ./yostalgia/views/file_picker_input
//= require ./yostalgia/views/alert_message_view
//= require ./yostalgia/views/post/form_overlay_view
//= require ./yostalgia/views/user/profile_photos_view
//= require ./yostalgia/views/components/token_input
//= require ./yostalgia/controllers/_base
//= require ./yostalgia/controllers/_overlay_controller
//= require ./yostalgia/controllers/post/form_overlay_controller
//= require ./yostalgia/controllers/user/profile_photos_controller
//= require ./yostalgia/models/_base
//= require ./yostalgia/models/trackable
//= require ./yostalgia/models/notifiable
//= require ./yostalgia/models/attachable
//= require ./yostalgia/models/commentable
//= require ./yostalgia/models/likeable
//= require ./yostalgia/components/debounce
//= require ./yostalgia/routes/application_routes

//= require_tree ./yostalgia/components
//= require_tree ./yostalgia/models
//= require_tree ./yostalgia/controllers
//= require_tree ./yostalgia/views
//= require_tree ./yostalgia/helpers
//= require_tree ./yostalgia/templates
//= require_tree ./yostalgia/routes

/*
  We're not interested in watching `mouseMove` or `touchMove` events on an Ember views,
  so we remove them from the events the EventDispatcher watches for.
*/
Ember.EventDispatcher.reopen({
  events: {
    touchstart  : 'touchStart',
    touchend    : 'touchEnd',
    touchcancel : 'touchCancel',
    keydown     : 'keyDown',
    keyup       : 'keyUp',
    keypress    : 'keyPress',
    mousedown   : 'mouseDown',
    mouseup     : 'mouseUp',
    contextmenu : 'contextMenu',
    click       : 'click',
    dblclick    : 'doubleClick',
    focusin     : 'focusIn',
    focusout    : 'focusOut',
    mouseenter  : 'mouseEnter',
    mouseleave  : 'mouseLeave',
    submit      : 'submit',
    input       : 'input',
    change      : 'change',
    dragstart   : 'dragStart',
    drag        : 'drag',
    dragenter   : 'dragEnter',
    dragleave   : 'dragLeave',
    dragover    : 'dragOver',
    drop        : 'drop',
    dragend     : 'dragEnd'
  }
});

Yostalgia = Ember.Application.create({
  LOG_STACKTRACE_ON_DEPRECATION : true,
  LOG_BINDINGS                  : true,
  LOG_TRANSITIONS               : true,
  LOG_TRANSITIONS_INTERNAL      : true,
  LOG_VIEW_LOOKUPS              : true,
  LOG_ACTIVE_GENERATION         : true
});

Ember.TextField.reopen({
  attributeBindings: ['type', 'value', 'size', 'pattern', 'name', 'min', 'max',
                      'accept', 'autocomplete', 'autosave', 'formaction',
                      'formenctype', 'formmethod', 'formnovalidate', 'formtarget',
                      'height', 'inputmode', 'list', 'multiple', 'pattern', 'step',
                      'width', 'autofocus']
});

Yostalgia.reopen({

  MS_DATE_FORMAT: 'YYYY-MM-DD HH:mm:ss.SSS ZZ',

  isHighResDisplay: function() {
    if (window.matchMedia) {
      var mq = window.matchMedia("only screen and (-moz-min-device-pixel-ratio: 1.3), only screen and (-o-min-device-pixel-ratio: 2.6/2), only screen and (-webkit-min-device-pixel-ratio: 1.3), only screen  and (min-device-pixel-ratio: 1.3), only screen and (min-resolution: 1.3dppx)");
      if (mq && mq.matches) {
        return true;
      }
    }

    return false;
  }.property(),

  thumbSizes: [
    [42, 42],
    [47, 47],
    [50, 50],
    [52, 52],
    [100, 100],
    [140, 140],
    [150, 150],
    [280, 280]
  ]

});

var pageHiddenAttribute, visibilityChangeEvent;
if (typeof document.hidden !== "undefined") { // Opera 12.10 and Firefox 18 and later support
  pageHiddenAttribute = "hidden";
  visibilityChangeEvent = "visibilitychange";
} else if (typeof document.mozHidden !== "undefined") {
  pageHiddenAttribute = "mozHidden";
  visibilityChangeEvent = "mozvisibilitychange";
} else if (typeof document.msHidden !== "undefined") {
  pageHiddenAttribute = "msHidden";
  visibilityChangeEvent = "msvisibilitychange";
} else if (typeof document.webkitHidden !== "undefined") {
  pageHiddenAttribute = "webkitHidden";
  visibilityChangeEvent = "webkitvisibilitychange";
}


// Really simple query parameter access
(function($) {
  $.QueryString = (function(a) {
    if (a == "") return {};
    var b = {};
    for (var i = 0; i < a.length; ++i)
    {
      var p=a[i].split('=');
      if (p.length != 2) continue;
      b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
    }
    return b;
  })(window.location.search.substr(1).split('&'))
})(jQuery);
