import Foundation
import AppKit

import ArgumentParser

enum ScalingOption {
    case center
    case zoom
    case stretch
    case none

    var values: (NSNumber, UInt) {
        switch self {
        case .center:
            return (0, NSImageScaling.scaleProportionallyUpOrDown.rawValue)
        case .zoom:
            return (1, NSImageScaling.scaleProportionallyUpOrDown.rawValue)
        case .stretch:
            return (0, NSImageScaling.scaleAxesIndependently.rawValue)
        case .none:
            return (0, NSImageScaling.scaleNone.rawValue)
        }
    }

    static func fromString(_ value: String) -> ScalingOption? {
        switch value {
        case "center":
            return ScalingOption.center
        case "zoom":
            return ScalingOption.zoom
        case "stretch":
            return ScalingOption.stretch
        case "none":
            return ScalingOption.none
        default:
            return nil
        }
    }
}

struct WallpaperOption {
    var scaling = ScalingOption.none
    var color = NSColor.black
}

func changeWallpaper(_ imagePath: String, options: WallpaperOption) throws {
    let wallpaperUrl = URL(fileURLWithPath: imagePath)
    let optionsDict = wallpaperOptionsToDict(options)

    for screen in NSScreen.screens{
        try NSWorkspace.shared.setDesktopImageURL(
            wallpaperUrl, for: screen, options: optionsDict
        )
    }
}

func wallpaperOptionsToDict(_ options: WallpaperOption) -> [NSWorkspace.DesktopImageOptionKey : Any] {
    let (clipping, scaling) = options.scaling.values
    let optionDict: [NSWorkspace.DesktopImageOptionKey : Any] = [
        .imageScaling: scaling,
        .allowClipping: clipping,
        .fillColor: options.color,
    ]
    return optionDict
}

func stringToNSColor(_ strColor: String) -> NSColor? {
    if strColor.count != 7 {
        return nil
    }
    var start: String.Index, end: String.Index

    start = strColor.index(strColor.startIndex, offsetBy: 1)
    end = strColor.index(start, offsetBy: 2)
    guard let red = Int(strColor[start..<end], radix: 16) else {
        return nil
    }

    start = strColor.index(strColor.startIndex, offsetBy: 3)
    end = strColor.index(start, offsetBy: 2)
    guard let green = Int(strColor[start..<end], radix: 16) else {
        return nil
    }

    start = strColor.index(strColor.startIndex, offsetBy: 5)
    end = strColor.index(start, offsetBy: 2)
    guard let blue = Int(strColor[start..<end], radix: 16) else {
        return nil
    }
    return NSColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
}

func stringsToWallpaperOptions(_ scaleString: String, _ colorString: String) -> WallpaperOption? {
    guard let scale = ScalingOption.fromString(scaleString) else {
        return nil
    }
    guard let color = stringToNSColor(colorString) else {
        return nil
    }
    return WallpaperOption(scaling: scale, color: color)
}

enum WallpaperError: Error {
    case parserError(String)
}

struct Wallpaper: ParsableCommand {

    @Option(help: "Scaling option: center, zoom, stretch, none. (default zoom)")
    var scale: String?

    @Option(help: "Fill color in RGB.")
    var fill: String?

    @Argument(help: "Path to wallpaper image.")
    var path: String

    func run() throws {
        let scaleValue = scale ?? "zoom"
        let colorValue = fill ?? "#000000"
        guard let options = stringsToWallpaperOptions(scaleValue, colorValue) else {
            throw WallpaperError.parserError("Failed to create options from scale and color")
        }

        let spaces = try querySpaces()
        let focused = getFocusedSpace(spaces)

        for space in spaces {
            if let index = space["index"] as? Int32 {
                switchSpace(index: index)
                try changeWallpaper(path, options: options)
            }
        }
        switchSpace(index: focused)
    }
}

Wallpaper.main()
