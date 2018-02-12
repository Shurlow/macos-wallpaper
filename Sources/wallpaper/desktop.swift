import AppKit
import SQLite

func setDesktopImage(screen: NSScreen, imgPath: String, scale: String?, color: NSColor? = nil) {

  let imgurl = NSURL.fileURL(withPath: imgPath)
  let workspace = NSWorkspace.shared

  var options: [NSWorkspace.DesktopImageOptionKey: Any] = [:]

  if color == nil {
    options[NSWorkspace.DesktopImageOptionKey.fillColor] = randomColor()
  } else {
    options[NSWorkspace.DesktopImageOptionKey.fillColor] = color
  }

  if scale == "fill" {
    options[NSWorkspace.DesktopImageOptionKey.imageScaling] = 3 // enum case scaleProportionallyUpOrDown = 3
    options[NSWorkspace.DesktopImageOptionKey.allowClipping] = true
  }

  if scale == "fit" {
    options[NSWorkspace.DesktopImageOptionKey.imageScaling] = 3 // enum case scaleProportionallyUpOrDown = 3
    options[NSWorkspace.DesktopImageOptionKey.allowClipping] = false
  }

  if scale == "stretch" {
    options[NSWorkspace.DesktopImageOptionKey.imageScaling] = 1 // enum case scaleAxesIndependently = 1
    options[NSWorkspace.DesktopImageOptionKey.allowClipping] = true
  }

  if scale == "center" {
    options[NSWorkspace.DesktopImageOptionKey.imageScaling] = 2 // enum case scaleNone = 2
    options[NSWorkspace.DesktopImageOptionKey.allowClipping] = false
  }

  do {
    try workspace.setDesktopImageURL(imgurl, for: screen, options: options)
  } catch {
    print(error)
  }
}

func getDesktopImage() -> String {
  let workspace = NSWorkspace.shared
  let screen = NSScreen.main
  let path = workspace.desktopImageURL(for: screen!)!.path
  var isDir: ObjCBool = false

  FileManager.default.fileExists(atPath: path, isDirectory: &isDir)

  if isDir.boolValue {
    let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let dbPath = NSString.path(withComponents: [dirs[0], "Dock/desktoppicture.db"])

    do {
      let db = try Connection(dbPath)
      let column = Expression<String>("value")
      let data = Table("data").select(column)
      let lastRow = Array(try db.prepare(data)).last
      let img = try lastRow!.get(column)
      let imgPath = NSString.path(withComponents: [path, img])
      return imgPath
    } catch {
      print(error)
    }
  }

  return path
}

func randomFloat() -> CGFloat {
  return CGFloat(arc4random()) / CGFloat(UInt32.max)
}

func randomColor() -> NSColor {
  return NSColor(
    red: randomFloat(),
    green: randomFloat(),
    blue: randomFloat(),
    alpha: 1
  )
}
