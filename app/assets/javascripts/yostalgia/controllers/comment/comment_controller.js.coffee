Yostalgia.CommentController = Yostalgia.ObjectController.extend

  isOwnComment: (->
    @session.get('user.id') == @get('user.id')
  ).property('session.user.id', 'user.id')

  actions:
    deleteComment: ->
      comment = @get('model')
      comment.deleteRecord()
      comment.save().then (=>
        @send 'pushAlert', 'warning', 'Comment removed'
      ), (error) =>
        comment.rollback()
        @send 'pushAlert', 'alert', 'Uh-oh', 'Something went wrong :('
        console.log error
