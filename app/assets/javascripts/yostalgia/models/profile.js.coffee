Yostalgia.Profile = Yostalgia.Attachable.extend

  user: DS.belongsTo('user', { async: true, readOnly: true })
  photo: DS.belongsTo('attachment', { async: true, readOnly: true })
  coverPhoto: DS.belongsTo('attachment')
  versions: DS.hasMany('profileVersion', { async: true, readOnly: true })

  firstName:    DS.attr('string')
  lastName:     DS.attr('string')
  gender:       DS.attr('string')
  aboutMe:      DS.attr('string')
  location:     DS.attr('string')
  education:    DS.attr('string')
  occupation:   DS.attr('string')
  dateOfBirth:  DS.attr('onlyDate')

  fullName: ((key, value)->
    if arguments.length == 2 and value
      name = value.split(' ')
      @set 'firstName', name[0]
      @set 'lastName', name.slice(1).join(' ')

    if @get('firstName') or @get('lastName')
      $.trim("#{@get('firstName')} #{@get('lastName')}")
    else
      null
  ).property('firstName', 'lastName')

  isMale: (->
    if @get('gender') == 'Male' then true else false
  ).property('gender')

  isFemale: (->
    if @get('gender') == 'Female' then true else false
  ).property('gender')

  dobDisplay: (->
    if @get('dateOfBirth')
      moment(@get('dateOfBirth')).format("LL")
  ).property('dateOfBirth')

  age: (->
    moment().diff @get('dateOfBirth'), 'years'
  ).property('dateOfBirth')
