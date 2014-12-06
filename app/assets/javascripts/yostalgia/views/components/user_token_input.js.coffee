KEY =
  BACKSPACE: 8
  TAB: 9
  ENTER: 13
  ESCAPE: 27
  SPACE: 32
  PAGE_UP: 33
  PAGE_DOWN: 34
  END: 35
  HOME: 36
  LEFT: 37
  UP: 38
  RIGHT: 39
  DOWN: 40
  NUMPAD_ENTER: 108
  COMMA: 188

Yostalgia.UserTokenInputComponent = Yostalgia.TokenInputComponent.extend
  tokenProperty: 'profile.fullName'
  resultProperty: 'profile.fullName'

Yostalgia.UserTokenInputTokenComponent = Yostalgia.TokenInputTokenComponent.extend()

Yostalgia.UserTokenInputResultComponent = Yostalgia.TokenInputResultComponent.extend()
