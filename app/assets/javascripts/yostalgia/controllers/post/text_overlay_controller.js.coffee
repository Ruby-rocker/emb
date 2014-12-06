Yostalgia.PostTextOverlayController = Yostalgia.OverlayController.extend

  comments: null
  commentsLoading: false

  show: (post) ->
    @set('model', post)
    @set 'comments', null
    @set 'comments', @store.filter 'comment', (comment) ->
      comment.get('commentable.constructor') == Yostalgia.Post &&
      comment.get('commentable.id') == post.get('id')
    @set 'commentsLoading', true
    @store.find('comment', post_id: post.get('id')).then =>
      @set 'commentsLoading', false
