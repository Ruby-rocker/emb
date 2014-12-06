Yostalgia.FeedItemPostCreateView = Yostalgia.View.extend

  templateName: 'feed_item/post_create'

  tagName: 'li'
  classNames: ['feed-item']

  oldTotalLikeCount: 0

  didInsertElement: ->
    @get('parentView').send('reloadLayout')

  hasMedia: (->
    @get('controller.post.hasMedia')
  ).property('controller.post.hasMedia')

  totalLikesChanged: (->
    totalLikeCount = @get 'controller.post.totalLikeCount'
    oldTotalLikeCount = @get 'oldTotalLikeCount'

    if oldTotalLikeCount > 0 && totalLikeCount == 0
      @get('parentView').send 'reloadLayout'

    if oldTotalLikeCount == 0 && totalLikeCount > 0
      @get('parentView').send 'reloadLayout'

    @set 'oldTotalLikeCount', totalLikeCount
  ).observes('controller.post.totalLikeCount')
