Yostalgia.UserFriendsController = Yostalgia.ArrayController.extend

  needs: ['user']

  searchTerm: null

  user: (->
    @get('controllers.user.content')
  ).property('controllers.user.content')

  filteredContent: (->
    if !@blank 'searchTerm'
      searchTerm = @get('searchTerm').toLowerCase()
      @filter (user) ->
        user.get('profile.fullName').toLowerCase().indexOf(searchTerm) > -1
    else
      @get('model')
  ).property('@each.profile.fullName', 'searchTerm')
