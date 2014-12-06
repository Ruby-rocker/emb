forEach = Ember.EnumerableUtils.forEach

Yostalgia.FilePickerInput = Ember.View.extend
  tagName: 'button'
  attributeBindings: ['class']

  # our default services
  # full list at https://developers.filepicker.io/docs/web/#pick
  services: [
    'COMPUTER'
    'FACEBOOK'
    'INSTAGRAM'
    'FLICKR'
    'DROPBOX'
    'WEBCAM'
    'URL'
  ]

  multiple: false

  # default filepicker options
  mimetypes: ['image/*']
  extensions: null
  maxSize: null
  openTo: null
  UIContainer: 'modal'
  debug: false
  multiple: false
  replace: false

  onSuccess: (FPFiles) ->
    if @get 'multiple'
      if @get('replace') == false
        old_files = @get('value')
        new_files = old_files.concat(FPFiles)
        @set 'value', new_files
      else
        @set 'value', FPFiles
    else
      @set 'value', FPFiles[0]

  onError: (FPError) ->
    console.log FPError.toString()

  click: (event) ->
    event.preventDefault()

    pick_option_attrs = [
      'services'
      'mimetypes'
      'extensions'
      'multiple'
      'maxSize'
      'openTo'
      'UIContainer'
      'debug'
    ]

    pick_options = {}

    forEach pick_option_attrs, (attribute) =>
      if @get attribute
        pick_options[attribute] = @get attribute

    now_utc = moment.utc()
    store_options = { path: "#{now_utc.format('YYYY/MM/DD/HH')}/" }

    filepicker.pickAndStore pick_options, store_options,
      (FPFile) =>
        @onSuccess(FPFile)
      (FPError) =>
        @onError(FPError)
