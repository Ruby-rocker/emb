Yostalgia.PostIndexController = Yostalgia.ObjectController.extend

  needs: ['application', 'user']

  selectedAttachment: null
  comments: null
  commentsLoading: false

  ### actions ###

  actions:
    close: ->
      prev_route = @get 'controllers.application.previousRouteForPost'
      prev_user = @get 'controllers.application.previousUserForPost'
      if prev_route == 'user' and prev_user
        @transitionToRoute 'user', prev_user
      else if prev_route == 'user_feed.posts' and prev_user
        prev_date = @get('controllers.application.previousDateForPost') || 'today'
        @transitionToRoute 'user_feed.posts', prev_user, prev_date
      else if prev_route == 'user.photos' and prev_user
        @transitionToRoute 'user.photos', prev_user
      else if prev_route == 'event.posts'
        event = @get 'controllers.application.previousEventForPost'
        @transitionToRoute 'event.posts', event
      else
        @transitionToRoute 'newsfeed'

    selectAttachment: (attachment) ->
      @clearSelectedAttachments()
      attachment.set('isSelected', true)
      @set 'selectedAttachment', attachment

    nextAttachment: ->
      @advanceAttachment(1)

    previousAttachment: ->
      @advanceAttachment(-1)


  ### properties ###

  nextButtonActive: (->
    @get('attachments').indexOf(@get('selectedAttachment')) != @get('attachments.length') - 1
  ).property('selectedAttachment')

  previousButtonActive: (->
    @get('attachments').indexOf(@get('selectedAttachment')) != 0
  ).property('selectedAttachment')


  ### methods ###

  clearSelectedAttachments: ->
    @get('attachments').forEach (attachment) ->
      attachment.set('isSelected', false)

  advanceAttachment: (delta) ->
    attachments = @get('attachments')
    index = attachments.indexOf(@get('selectedAttachment')) + delta

    # loop
    index = 0 if index >= attachments.get('length')
    index = attachments.get('length') - 1 if index < 0

    attachment = attachments.objectAt(index)
    @send('selectAttachment', attachment) if attachment
