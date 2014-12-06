Yostalgia.Activity = Yostalgia.Trackable.extend

  owner: DS.belongsTo('user', { async: true })
  recipient: DS.belongsTo('user', { async: true })
  trackable: DS.belongsTo('trackable', { polymorphic: true })

  key: DS.attr('string')
  parameters: DS.attr('string')
  postedAt: DS.attr('date')
  userfeedPostedAt: DS.attr('date')
  trackablePrivacy: DS.attr('string')
  createdAt: DS.attr('date', { readOnly: true })
  updatedAt: DS.attr('date', { readOnly: true })

  templateName: (->
    templateName = @get('key').replace('.','_')
    "feed_item/#{templateName}"
  ).property('key')

  controllerType: (->
    controllerName = @get('key').replace('.','_').classify()
    "FeedItem#{controllerName}"
  ).property('key')

  isPostCreate: (->
    @get('key') == 'post.create'
  ).property('key')

  isEventCreate: (->
    @get('key') == 'event.create'
  ).property('key')

  isCommentCreate: (->
    @get('key') == 'comment.create'
  ).property('key')

  isPostMention: (->
    @get('key') == 'post.mentioned'
  ).property('key')

  isEventMention: (->
    @get('key') == 'event.mentioned'
  ).property('key')

  isCommentMention: (->
    @get('key') == 'comment.mentioned'
  ).property('key')

  isMention: Ember.computed.any 'isPostMention', 'isEventMention', 'isCommentMention'

  isTag: (->
    @get('key') == 'post.tagged'
  ).property('key')

  flashbackDate: (->
    moment(@get('postedAt')).format('MM-DD-YYYY')
  ).property('postedAt')
