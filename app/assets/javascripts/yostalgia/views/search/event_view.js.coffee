Yostalgia.SearchEventView = Yostalgia.View.extend

  tagName: 'li'
  classNames: ['post', 'search-results', 'with-media']
  classNameBindings: ['isLimit:hide_element']
  templateName: 'search/event'

  event: null

  isLimit: (->
    if @get('_parentView.contentIndex') < 5 then false else true
  ).property('_parentView.contentIndex')