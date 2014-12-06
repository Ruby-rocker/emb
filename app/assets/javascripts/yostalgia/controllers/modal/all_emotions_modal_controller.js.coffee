Yostalgia.AllEmotionsModalController = Yostalgia.ObjectController.extend

  selectedEmotion: null

  selectedLikes: null
  users: Ember.computed.mapBy 'selectedLikes', 'user'

  actions:
    changeEmotion: (emotion) ->
      @set 'selectedEmotion', parseInt(emotion)

    close: ->
      @send 'closeModal'

  selectedEmotionChanged: (->
    @set 'selectedLikes', @get('store').filter 'like', (like) =>
      like.get('likeable') == @get('model') &&
      like.get('emotion') == @get('selectedEmotion')
  ).observes('selectedEmotion')

  emotions: (->
    emotions = Ember.A()
    for id, name of Yostalgia.Like.EMOTIONS
      emotion = new Ember.Object()
      emotion.set 'emotion', parseInt(id)
      emotion.set 'count', @get('likeCounts')[id]
      emotion.set 'name', name
      emotion.set 'icon', Yostalgia.Like.ICONS[id]
      emotion.set 'selected', parseInt(id) == @get('selectedEmotion')
      emotions.pushObject emotion

    emotions
  ).property('likeCounts', 'selectedEmotion')

  selectedEmotionCount: (->
    count = @get('likeCounts')[@get('selectedEmotion')]
    text = Yostalgia.Like.COUNTS[@get('selectedEmotion')]
    "#{count} #{text}"
  ).property('selectedEmotion', 'likeCounts')

  selectedEmotionIcon: (->
    Yostalgia.Like.ICONS[@get('selectedEmotion')]
  ).property('selectedEmotion')

Yostalgia.register 'controller:allEmotionsModal', Yostalgia.AllEmotionsModalController, singleton: false
