JsOsaDAS1.001.00bplist00�Vscript_�const SystemEvents = Application('System Events')

const keyCodes = {
  'ArrowLeft': 123,
  'ArrowRight': 124,
  'ArrowDown': 125,
  'ArrowUp': 126,
  'Backspace': 51,
  'Enter': 36,
  'Escape': 53,
  'Space': 49,
  'Tab': 48,
}

function run(args) {
  let key = args[0],
      using = args[1] ? args[1].split(',').map(k => `${k} down`) : []

  if (key in keyCodes)
    SystemEvents.keyCode(keyCodes[key], { using })
  else
    SystemEvents.keystroke(key, { using })
}                              �jscr  ��ޭ