JsOsaDAS1.001.00bplist00�Vscript_fvar SystemEvents = Application('System Events')

var keyCodes = {
  'ArrowLeft': 123,
  'ArrowRight': 124,
  'ArrowDown': 125,
  'ArrowUp': 126,
  'Enter': 36,
  'Space': 49,
  'Escape': 53,
  'Backspace': 51,
}

function run(args) {
  var key = args[0]
  if (key in keyCodes)
    SystemEvents.keyCode(keyCodes[key])
  else
    SystemEvents.keystroke(key)
}
                              |jscr  ��ޭ