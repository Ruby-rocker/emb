Yostalgia.SearchPostView = Yostalgia.View.extend

  tagName: 'li'
  classNames: ['post', 'search-results']
  classNameBindings: ['isLimit:hide_element']
  templateName: 'search/post'

  post: null

  isLimit: (->
    if @get('_parentView.contentIndex') < 5 then false else true
  ).property('_parentView.contentIndex')