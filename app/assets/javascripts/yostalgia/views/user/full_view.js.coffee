Yostalgia.UserFullView = Yostalgia.OverlayView.extend
  classNames: ['modal', 'modal-transparent', 'modal-left', 'modal-inner']

  isCurrentUser: (->
    if @session && currentUserId = @session.get('user.id')
      return true if parseInt(@get('controller.content.id')) == currentUserId

    false
  ).property('session.user.id')
