Yostalgia.UserProfileVersionController = Yostalgia.UserIndexController.extend

  user: Ember.computed.alias('controllers.user.model')
  profile: Ember.computed.alias('model')

  selectedDate: (->
    @get('timestamp')
  ).property('timestamp')

  dateChanged: (->
    selectedDate = moment(@get('selectedDate'))
    today = moment().startOf('day')
    if selectedDate.startOf('day').isSame(today)
      @transitionToRoute('user.index')
    else
      @transitionToRoute('user.profile_version', selectedDate.format('MM-DD-YYYY'))
  ).observes('selectedDate').on('init')

  selectedDateDisplay: (->
    Yostalgia.Utilities.simpleDateDisplay(@get('selectedDate'))
  ).property('selectedDate')
