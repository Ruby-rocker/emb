forEach = Ember.EnumerableUtils.forEach

Yostalgia.FilePickerLink = Yostalgia.FilePickerInput.extend
  tagName: 'a'

  attributeBindings: 'href'
  href: '#'
