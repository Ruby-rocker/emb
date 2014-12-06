Ember.debouncedObserver = (keys..., time, func) ->
  Em.observer ->
    Em.run.debounce @, func, time
  , keys...

Ember.throttledObserver = (keys..., time, func) ->
  Em.observer ->
    Em.run.throttle @, func, time
  , keys...
