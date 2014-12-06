Ember.Handlebars.helper 'attachmentImage', (attachment, options) ->
  if attachment && (attachment.url || attachment.get('url'))
    hash = options.hash
    imageUrl = Yostalgia.Utilities.imageUrl(attachment, hash)

    cssClass = hash.cssClass || ""
    title = hash.title || ""
    alt = hash.alt || ""

    imageWidth = if attachment.get? then attachment.get('width') else attachment.width
    imageHeight = if attachment.get? then attachment.get('height') else attachment.height
    ratio = imageWidth / imageHeight

    unless hash.excludeSize
      unless hash.excludeWidth
        if hash.width
          width = hash.width
        else
          width = Math.ceil(hash.height * ratio)

        if width > imageWidth
          width = imageWidth

      unless hash.excludeHeight
        if hash.height
          height = hash.height
        else
          height = Math.ceil(hash.width / ratio)

        if height > imageHeight
          height = imageHeight

    imgTag = "<img "
    imgTag += "src=\"#{imageUrl}\" title=\"#{title}\" alt=\"#{alt}\" class=\"#{cssClass}\" "
    imgTag += "style=\""
    imgTag += "width: #{width}px; " if width
    imgTag += "height: #{height}px;" if height
    imgTag += "\">"

    new Handlebars.SafeString(imgTag)
