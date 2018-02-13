import Foundation
import Vapor

let eventSource = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
func makeCGEvent(_ json: JSON?) -> CGEvent? {
  let key = json?.object?["key"]?.string
  let down = json?.object?["down"]?.bool

  // from /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
  let keyCode: CGKeyCode? = {
    switch key! {
    case "Enter":      return 0x24
    case " ":          return 0x31
    case "Escape":     return 0x35
    case "Meta":       return 0x37
    case "Shift":      return 0x38
    case "Alt":        return 0x3A
    case "ArrowLeft":  return 0x7B
    case "ArrowRight": return 0x7C
    case "ArrowDown":  return 0x7D
    case "ArrowUp":    return 0x7E
    default: return nil
    }
  }()

  guard keyCode != nil && down != nil else { return nil }
  return CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode!, keyDown: down!)
}

let drop = try Droplet()

drop.socket("stroke") { req, ws in
  let pingTimer: DispatchSourceTimer = DispatchSource.makeTimerSource()
  pingTimer.schedule(deadline: .now(), repeating: .seconds(25))
  pingTimer.setEventHandler { try? ws.ping() }
  pingTimer.resume()

  ws.onClose = { ws, _, _, _ in
    pingTimer.cancel()
  }

  ws.onText = { ws, text in
    if let event = makeCGEvent(try JSON(bytes: text)) {
      event.post(tap: CGEventTapLocation.cghidEventTap)
    }
  }
}

drop.get("/") { req in
  return try View(bytes: """
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons"
              rel="stylesheet" />
        <style>
          body {
            padding: 0;
            margin: 0;
          }

          textarea {
            width: 100vw;
            height: 10vh;
            margin: 0;
            box-sizing: border-box;
            font: large -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol';
          }

          button.material-icons {
            margin: 0;
            width: 50vw;
            height: 90vh;
            font-size: 10vw;
            background: none;
            border: none;
            user-select: none;
            touch-action: manipulation;
          }
        </style>
      </head>
      <body>
        <textarea autofocus placeholder="Focus to use a physical keyboard"></textarea>
        <button class="material-icons" value="ArrowLeft">
          keyboard_arrow_left
        </button><!--
    --><button class="material-icons" value="ArrowRight">
          keyboard_arrow_right
        </button>
        <script>
          const ws = new WebSocket(`ws://${location.host}/stroke`)
          ws.onerror = (e) => {
            console.log('error', e)
          }

          for (const direction of ['down', 'up']) {
            document.querySelector('textarea').addEventListener(`key${direction}`, e => {
              ws.send(JSON.stringify({ key: e.key, down: direction === 'down' }))
            })
            document.body.addEventListener(`mouse${direction}`, e => {
              if (e.target.nodeName === 'BUTTON')
                ws.send(JSON.stringify({ key: e.target.value, down: direction === 'down' }))
            })
          }
        </script>
      </body>
    </html>
    """)
}

try drop.run()
