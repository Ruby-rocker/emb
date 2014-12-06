Yostalgia.AlertMessageContainerView = Ember.CollectionView.extend

  classNames: ['alert-message-container']

  itemViewClass: Yostalgia.AlertMessageView

  content: Ember.computed.oneWay 'controller.alertMessages'
