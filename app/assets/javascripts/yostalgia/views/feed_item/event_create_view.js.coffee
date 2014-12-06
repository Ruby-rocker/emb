Yostalgia.FeedItemEventCreateView = Yostalgia.View.extend

  templateName: 'feed_item/event_create'

  tagName: 'li'
  classNames: ['feed-item', 'post', 'with-media']

  didInsertElement: ->
    @get('parentView').send('reloadLayout')
