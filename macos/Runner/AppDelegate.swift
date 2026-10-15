import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    // NSApplication responde a `orderFrontStandardAboutPanel:` antes que el
    // delegate, así que se redirige el ítem "About" del menú a este objeto.
    let aboutItem = NSApp.mainMenu?.items.first?.submenu?.items.first {
      $0.action == #selector(NSApplication.orderFrontStandardAboutPanel(_:))
    }
    aboutItem?.target = self
    aboutItem?.action = #selector(showAboutPanel(_:))
  }

  /// Panel "Acerca de": nombre, versión, ícono y copyright salen del
  /// Info.plist (ver Configs/AppInfo.xcconfig); aquí solo se agregan los
  /// créditos.
  @objc func showAboutPanel(_ sender: Any?) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let credits = NSAttributedString(
      string: "Seguimiento de aplicaciones de Ota Labs.",
      attributes: [
        .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
        .foregroundColor: NSColor.secondaryLabelColor,
        .paragraphStyle: paragraph,
      ]
    )
    NSApp.orderFrontStandardAboutPanel(options: [.credits: credits])
  }
}
