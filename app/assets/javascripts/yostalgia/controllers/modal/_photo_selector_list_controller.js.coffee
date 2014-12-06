Yostalgia.PhotoSelectorListController = Yostalgia.ArrayController.extend

  needs: ['coverPhotoSelectorModal']

  sortProperties: ['createdAt']
  sortAscending: false

  user: Ember.computed.alias('session.user')
  selectController: Ember.computed.alias('controllers.coverPhotoSelectorModal')
  selectedPhoto: Ember.computed.alias('selectController.selectedPhoto')

  actions:
    selectPhoto: (photo) ->
      @set 'selectedPhoto', photo
