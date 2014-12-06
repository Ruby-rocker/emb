Yostalgia.Attachment = Yostalgia.Likeable.extend

  user: DS.belongsTo 'user', async: true, readOnly: true
  attachable: DS.belongsTo 'attachable', polymorphic: true
  comments: DS.hasMany 'comment', async: true, readOnly: true

  url:        DS.attr 'string'
  filename:   DS.attr 'string'
  s3_key:     DS.attr 'string'
  mimetype:   DS.attr 'string'
  filesize:   DS.attr 'number'
  width:      DS.attr 'number'
  height:     DS.attr 'number'
  subType:    DS.attr 'string'
  mediaType:  DS.attr 'string'
  createdAt:  DS.attr 'date', readOnly: true
  commentsCount:  DS.attr 'number', readOnly: true

  _fpFileObject: null

  save: ->
    superFunction = @__nextSuper.bind(@)

    new Ember.RSVP.Promise (resolve, reject) =>

      meta_request_options =
        url: "#{@get('url')}/metadata"
        type: 'get'
        data:
          width: true
          height: true
        dataType: 'json'
        success: (data) =>
          @set 'width', data.width
          @set 'height', data.height

      $.ajax(meta_request_options).always =>
        superFunction().then =>
          resolve @
        , (error) ->
          reject error

  fpFile: ((key, value) ->
    if arguments.length > 1
      @set '_fpFileObject', value

      if value
        @setProperties
          url: value.url
          filename: value.filename
          s3_key: value.key
          mimetype: value.mimetype
          filesize: value.size
      else
        @setProperties
          url: null
          filename: null
          s3_key: null
          mimetype: null
          filesize: null

    @get '_fpFileObject'
  ).property()

  isPostAttachment: (->
    @get('attachable.constructor') == Yostalgia.Post
  ).property('attachable')

  isAttachmentPublic: (->
    return !@get('attachable.isPrivate')
  ).property('attachable')

  isProfileAttachment: (->
    @get('attachable.constructor') == Yostalgia.Profile
  ).property('attachable')

  isCoverPhotoAttachment: (->
    @get('isProfileAttachment') && @get('sub_type') == 'cover_photo'
  ).property('isProfileAttachment', 'subType')

  ratio: (->
    if @get('width') && @get('height')
      @get('width') / @get('height')
  ).property('width', 'height')

  flashbackDate: (->
    moment(@get('createdAt')).format 'MM-DD-YYYY'
  ).property('createdAt')

  hasComments: (->
    @get('comments.length') > 0 || @get('commentsCount') > 0
  ).property('comments.length', 'commentsCount')
