Yostalgia.ProfileVersion = Yostalgia.Profile.extend

  profile: DS.belongsTo('profile', { async: true })

  timestamp:  DS.attr('onlyDate')
