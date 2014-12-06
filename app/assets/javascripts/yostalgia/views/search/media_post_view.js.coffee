Yostalgia.SearchMediaPostView = Yostalgia.View.extend

  tagName: 'li'
  classNames: ['post', 'search-results', 'media-list']
  classNameBindings: ['isLimit:hide_element']
  templateName: 'search/media_post'

  post: null

  isLimit: (->
    if @get('_parentView.contentIndex') < 5 then false else true
  ).property('_parentView.contentIndex')