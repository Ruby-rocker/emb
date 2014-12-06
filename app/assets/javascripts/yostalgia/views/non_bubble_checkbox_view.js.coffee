Yostalgia.NonBubbleCheckboxView = Ember.Checkbox.extend

  click: (event) ->
    event.stopPropagation()
    @$().parent().click()
