Yostalgia.CommentNewController = Yostalgia.ObjectController.extend

  body: null
  userSearchResults: Ember.A()

  submitDisabled: (->
    if @blank('body') then true else false
  ).property('body')

  actions:
    searchUsers: (term) ->
      unless Ember.isEmpty term
        @store.find('user', search: term, friends: true).then (users) =>
          @set 'userSearchResults', users

    save: ->
      commentable = @get('model')
      _this = this

      comment =
        body: @get('body')
        commentable: commentable

      comment = @get('store').createRecord('comment', comment)
      comment.save().then (comment) ->
        comment.get('commentable.comments').pushObject(comment)
      , (error) ->
        alert "Uh-oh, something went wrong :("
        console.log error

      @set('body', null)
