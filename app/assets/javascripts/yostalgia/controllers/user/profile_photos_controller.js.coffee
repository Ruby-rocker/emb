Yostalgia.ProfilePhotosController = Yostalgia.ArrayController.extend

  needs: ['user']

  selectedAttachment: null

  actions:
    selectAttachment: (attachment) ->
      @clearSelectedAttachments()
      attachment.set('isSelected', true)
      @set 'selectedAttachment', attachment
      @transitionToRoute 'profile_photos.photo', attachment

    nextAttachment: ->
      @advanceAttachment(1)

    previousAttachment: ->
      @advanceAttachment(-1)

    close: ->
      @transitionToRoute 'user.photos', @get('controllers.user.model')


  ### properties ###

  nextButtonActive: (->
    @get('model').indexOf(@get('selectedAttachment')) != @get('model.length') - 1
  ).property('selectedAttachment')

  previousButtonActive: (->
    @get('model').indexOf(@get('selectedAttachment')) != 0
  ).property('selectedAttachment')


  ### methods ###

  clearSelectedAttachments: ->
    @get('model').forEach (attachment) ->
      attachment.set('isSelected', false)

  advanceAttachment: (delta) ->
    attachments = @get('model')
    index = attachments.indexOf(@get('selectedAttachment')) + delta

    # loop
    index = 0 if index >= attachments.get('length')
    index = attachments.get('length') - 1 if index < 0

    attachment = attachments.objectAt(index)
    @send('selectAttachment', attachment) if attachment
