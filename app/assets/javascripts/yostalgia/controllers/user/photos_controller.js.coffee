Yostalgia.UserPhotosController = Yostalgia.ArrayController.extend

  needs: ['user']

  user: Ember.computed.alias('controllers.user.model')

  sortProperties: ['createdAt']
  sortAscending: false

  loadedForUser: null
  scrollPosition: 0
  loadingMore: false

  actions:
    getMore: ->
      return if @get 'loadingMore'
      return if !@get 'morePages'

      @set 'loadingMore', true

      load_params =
        page: @get('page') + 1
        user_id: @get('user.id')

      @get('store').find('attachment', load_params).then (photos) =>
        @get('model').pushObjects photos.content
        @set 'loadingMore', false


  totalPhotos: (->
    @get('store').metadataFor('attachment').total_photos
  ).property('model.length')

  totalProfilePhotos: (->
    @get('store').metadataFor('attachment').total_profile_photos
  ).property('model.length')

  totalCoverPhotos: (->
    @get('store').metadataFor('attachment').total_cover_photos
  ).property('model.length')

  page: (->
    @get('store').metadataFor('attachment').page
  ).property('model.length')

  morePages: (->
    morePages = @get('store').metadataFor('attachment').more_pages
    if morePages == 'yes' then true else false
  ).property('mmodel.length')
