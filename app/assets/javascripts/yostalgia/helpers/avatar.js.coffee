Ember.Handlebars.registerBoundHelper 'avatar', ((profile, options) ->
  if profile
    hash = options.hash
    avatarUrl = Yostalgia.Utilities.avatarUrl(profile, hash)

    cssClass = hash.cssClass || ""
    title = hash.title || profile.get('fullName') || ""
    alt = hash.alt || "Photo of #{profile.get('fullName')}"

    width = hash.size
    height = hash.size

    new Handlebars.SafeString """
      <img src="#{avatarUrl}" title="#{title}" alt="#{alt}" class="#{cssClass}" style="width: #{width}px; height: #{height}px">
    """
), 'photo', 'photo.url', 'gender'
