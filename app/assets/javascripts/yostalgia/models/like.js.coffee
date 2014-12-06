Yostalgia.Like = Yostalgia.Model.extend

  user: DS.belongsTo 'user', async: true, readOnly: true
  likeable: DS.belongsTo 'likeable', polymorphic: true, inverse: 'likes'

  emotion: DS.attr 'number'

  emotionName: (->
    Yostalgia.Like.EMOTIONS[@get 'emotion']
  ).property('emotion')

  emotionAction: (->
    Yostalgia.Like.ACTIONS[@get 'emotion']
  ).property('emotion')



### constants ###

LOVE = 1
HAPPY = 2
SAD = 3
LAUGH = 4
WOW = 5
INSPIRE = 6

EMOTIONS = {}
ACTIONS = {}
COUNTS = {}
ICONS = {}

EMOTIONS[LOVE] = 'love'
EMOTIONS[HAPPY] = 'happy'
EMOTIONS[SAD] = 'sad'
EMOTIONS[LAUGH] = 'laugh'
EMOTIONS[WOW] = 'surprise'
EMOTIONS[INSPIRE] = 'inspire'

ACTIONS[LOVE] = 'loved'
ACTIONS[HAPPY] = 'happy about'
ACTIONS[SAD] = 'sad about'
ACTIONS[LAUGH] = 'laughed at'
ACTIONS[WOW] = 'surprised by'
ACTIONS[INSPIRE] = 'inspired by'

COUNTS[LOVE] = 'Loves'
COUNTS[HAPPY] = 'Happy'
COUNTS[SAD] = 'Sad'
COUNTS[LAUGH] = 'Laughs'
COUNTS[WOW] = 'Wows'
COUNTS[INSPIRE] = 'Inspired'

ICONS[LOVE] = 'ss-like'
ICONS[HAPPY] = 'ss-like'
ICONS[SAD] = 'ss-like'
ICONS[LAUGH] = 'ss-like'
ICONS[WOW] = 'ss-like'
ICONS[INSPIRE] = 'ss-like'

### set up constants on class ###

Yostalgia.Like.reopenClass
  LOVE: LOVE
  HAPPY: HAPPY
  SAD: SAD
  LAUGH: LAUGH
  WOW: WOW
  INSPIRE: INSPIRE

  EMOTIONS: EMOTIONS
  ACTIONS: ACTIONS
  COUNTS: COUNTS
  ICONS: ICONS
