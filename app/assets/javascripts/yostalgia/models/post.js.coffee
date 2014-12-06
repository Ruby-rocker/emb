Yostalgia.Post = Yostalgia.Likeable.extend

  user: DS.belongsTo 'user', async: true, readOnly: true
  event: DS.belongsTo 'event'
  attachments: DS.hasMany 'attachment', async: true, readOnly: true
  comments: DS.hasMany 'comment', async: true, readOnly: true
  taggedUsers: DS.hasMany 'user', async: true

  title:    DS.attr 'string'
  body:     DS.attr 'string'
  bodyHtml: DS.attr 'string', readOnly: true
  postedAt: DS.attr 'postDate'
  isPrivate:  DS.attr 'boolean'
  commentsCount: DS.attr 'number', readOnly: true

  isEventPost: (->
    !@blank 'event'
  ).property('event')

  formattedPostedAt: (->
    if @get('postedAt')
      postedAt = moment(@get('postedAt'))
      postedAtUTC = moment(@get('postedAt')).utc()
      if postedAtUTC.hour() == 0 && postedAtUTC.minute() == 0 && postedAtUTC.second() == 0
        postedAtUTC.format('MM/DD/YYYY')
      else
        postedAt.format('MM/DD/YYYY - HH:mm')
    else
      '-'
  ).property('postedAt')

  hasMedia: (->
    @get('attachments.length') > 0
  ).property('attachments.length')

  hasMediaGroup: (->
    @get('attachments.length') > 1
  ).property('attachments.length')

  hasComments: (->
    @get('comments.length') > 0 || @get('commentsCount') > 0
  ).property('comments.length', 'commentsCount')

  # if today then set as now otherwise set to midnight on date
  adjustedPostedAt: ((key, value) ->
    if arguments.length == 2 and value
      postedAtDate = moment(moment(value).format('YYYY-MM-DD'))
      nowDate = moment(moment().format('YYYY-MM-DD'))
      diff = nowDate.diff(postedAtDate, 'days')

      if diff == 0
        @set 'postedAt', moment().toDate()
      else
        @set 'postedAt', moment(value).toDate()

    @get('postedAt')
  ).property()

  flashbackDate: (->
    moment(@get('postedAt')).format 'MM-DD-YYYY'
  ).property('postedAt')
