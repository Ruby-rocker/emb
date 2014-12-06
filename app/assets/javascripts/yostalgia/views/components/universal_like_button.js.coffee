Yostalgia.UniversalLikeButtonComponent = Ember.Component.extend

  classNameBindings: [':universal-like', 'positionStyle']

  #-- external attributes

  title: 'Like'
  href: '#'
  position: 'top'

  likeable: null

  #-- internal attributes

  isPopupVisible: false

  #-- actions

  actions:
    togglePopup: ->
      @toggleProperty 'isPopupVisible'
      if @get 'isPopupVisible'
        $('body').on 'click', $.proxy(@backgroundClick, @)
      else
        $('body').off 'click', $.proxy(@backgroundClick, @)

    selectEmotion: (emotion) ->
      @get('likeable').like parseInt(emotion)
      @hidePopup()

  backgroundClick: (e) ->
    unless @$().is(e.target) || @$().has(e.target).length
      @hidePopup()

  hidePopup: ->
    @set 'isPopupVisible', false

  #-- properties

  emotions: (->
    emotions = []
    for key, value of Yostalgia.Like.EMOTIONS
      emotions.push
        number: key
        name: value
        icon: Yostalgia.Like.ICONS[key]
        selected: parseInt(key) == @get('likeable.myLike.emotion')

    emotions
  ).property('likeable.myLike.emotion')

  isLiked: (->
    !Ember.isEmpty @get('likeable.myLike')
  ).property('likeable.myLike')

  positionStyle: (->
    "universal-like--#{@get('position')}"
  ).property('position')
