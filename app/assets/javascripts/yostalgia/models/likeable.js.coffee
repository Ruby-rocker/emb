Yostalgia.Likeable = Yostalgia.Commentable.extend
  myLike: DS.belongsTo 'like', readOnly: true
  likes: DS.hasMany 'like', async: true, readOnly: true
  likeCounts: DS.attr 'raw', readOnly: true

  like: (emotion) ->
    counts = jQuery.extend true, {}, @get('likeCounts')

    if !Ember.isEmpty @get('myLike')
      if @get('myLike.emotion') == emotion
        # delete existing like
        @get('myLike').deleteRecord()
        @get('myLike').save()
        @set 'myLike', null
        counts[emotion] -= 1
        @set 'likeCounts', counts

      else
        # update existing like
        oldEmotion = @get('myLike.emotion')
        @get('myLike').set 'emotion', emotion
        @get('myLike').save()
        counts[oldEmotion] -= 1
        counts[emotion] += 1
        @set 'likeCounts', counts

    else
      # create new like
      like =
        emotion: emotion
        likeable: @

      like = @get('store').createRecord 'like', like
      like.save().then (like) =>
        @set 'myLike', like
        counts[emotion] = 0 if !counts[emotion] # handle null value
        counts[emotion] += 1
        @set 'likeCounts', counts

  likeableName: (->
    if @get('constructor') == Yostalgia.Post
      'post'
    else if @get('constructor') == Yostalgia.Attachment
      'photo'
  ).property('constructor')

  formattedLikeCounts: (->
    formattedLikes = Ember.A()
    for emotion, count of @get('likeCounts')
      emotion = parseInt(emotion)
      if count > 0
        formattedLike = new Ember.Object()
        formattedLike.set 'icon', Yostalgia.Like.ICONS[emotion]
        formattedLike.set 'countText', @likeableCountText(emotion, count)
        formattedLike.set 'likeable', "this #{@get('likeableName')}"
        formattedLikes.pushObject formattedLike

    formattedLikes
  ).property('likeCounts', 'myLike.emotion')

  likeableCountText: (emotion, count) ->
    countText = ''
    youLiked = false

    if @get('myLike.emotion') == emotion
      youLiked = true
      count--
      countText = 'you '

    if (!youLiked && count > 0) || (youLiked && count > 0)
      countText += 'and ' if youLiked
      people = if count > 1 then 'person'.pluralize() else 'person'
      countText += "#{count} #{people} "

    if emotion == Yostalgia.Like.HAPPY or emotion == Yostalgia.Like.SAD
      if count > 1 || youLiked
        countText += 'are '
      else
        countText += 'is '

    if emotion == Yostalgia.Like.WOW || emotion == Yostalgia.Like.INSPIRE
      if youLiked && count == 0
        countText += 'are '

    countText += Yostalgia.Like.ACTIONS[emotion]

  totalLikeCount: (->
    total = 0
    for emotion, count of @get('likeCounts')
      total += count

    total
  ).property('likeCounts', 'myLike', 'myLike.emotion')
