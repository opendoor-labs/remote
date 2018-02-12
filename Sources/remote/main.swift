import Vapor
import Foundation

let drop = try Droplet()

drop.get("/") { req in
    return try drop.view.make("index.html")
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
        let key: CGKeyCode = {
          switch json.object?["key"]?.string ?? "" {
            case "ArrowRight": return 0x7c
            case "ArrowLeft":  return 0x7b
            default: return 0
          }
        }()
        let eventDown = CGEvent(keyboardEventSource: eventSource, virtualKey: key, keyDown: true)
        let eventUp = CGEvent(keyboardEventSource: eventSource, virtualKey: key, keyDown: false)
        eventDown?.post(tap: location)
        eventUp?.post(tap: location)
    }

    ws.onClose = { ws, _, _, _ in
        pingTimer?.cancel()
        pingTimer = nil
    }
}

try drop.run()
