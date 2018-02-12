import Vapor
import Foundation

let index: String = """
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
        touch-action: manipulation;
      }
    </style>
  </head>
  <body>
    <textarea autofocus placeholder="Type here"></textarea>
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
      ws.onmessage = (e) => {
        console.log('message', e)
      }

      document.querySelector('textarea').addEventListener('keydown', e => {
        switch (e.key) {
          case 'Alt':
          case 'Control':
          case 'Meta':
          case 'Shift':
            return;
          default:
            let using = [
              e.altKey   && 'alt',
              e.ctrlKey  && 'control',
              e.metaKey  && 'command',
              e.shiftKey && 'shift',
            ].filter(k => k).join(',')

            ws.send(JSON.stringify({ key: e.key, using }))
        }
      })

      document.body.addEventListener('click', e => {
        if (e.target.nodeName === 'BUTTON')
          ws.send(JSON.stringify({ key: e.target.value }))
      })
    </script>
  </body>
</html>
"""

let drop = try Droplet()

drop.get("/") { req in
    return try View(bytes: index)
}

drop.socket("stroke") { req, ws in
    var pingTimer: DispatchSourceTimer? = nil

    pingTimer = DispatchSource.makeTimerSource()
    pingTimer?.schedule(deadline: .now(), repeating: .seconds(25))
    pingTimer?.setEventHandler { try? ws.ping() }
    pingTimer?.resume()

    let eventSource = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
    let location = CGEventTapLocation.cghidEventTap

    ws.onText = { ws, text in
        let json = try JSON(bytes: text.makeBytes())
        let key: CGKeyCode? = {
          switch json.object?["key"]?.string ?? "" {
            case "ArrowRight": return 0x7c
            case "ArrowLeft":  return 0x7b
            default: return nil
          }
        }()
        if let keyCode = key {
            let eventDown = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: true)
            let eventUp = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: false)
            eventDown?.post(tap: location)
            eventUp?.post(tap: location)
        }
    }

    ws.onClose = { ws, _, _, _ in
        pingTimer?.cancel()
        pingTimer = nil
    }
}

try drop.run()
