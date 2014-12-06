Yostalgia.SearchResult = Yostalgia.Model.extend

  users: DS.hasMany('user')
  posts: DS.hasMany('post', { async: true })
  mediaPosts: DS.hasMany('post', { async: true })
  events: DS.hasMany('event', { async: true })

Yostalgia.SearchResult.reopenClass

  isExistInSearch: (user_id) ->
    $.ajax
      url: '/api/v1/search_results/is_exist_in_search'
      type: 'GET'
      data: { id: user_id }

  createSearchPassword: (password, user_id) ->
    $.ajax
      url: '/api/v1/search_results/create_search_password'
      type: 'GET'
      data: { pass: password, id: user_id }

  checkPassword: (password, user_id) ->
    $.ajax
      url: '/api/v1/search_results/password_validate'
      type: 'GET'
      data: { pass: password, id: user_id }

  searchResultRecord: (query, chk_private) ->
    $.ajax
      url: '/api/v1/search_results/'+query
      type: 'GET'
#      data: { query: query, chk_private: chk_private }
      data: { chk_private: chk_private }

  validateWithUserPassword: (password, user_id) ->
    $.ajax
      url: '/api/v1/search_results/validate_with_user_password'
      type: 'GET'
      data: { pass: password, id: user_id }