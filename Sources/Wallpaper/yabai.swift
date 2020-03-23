import AppKit

typealias SpacesJson = [Dictionary<String, Any>]

@discardableResult
func yabai(_ args: String...) -> (Int32, String) {
    let task = Process()
    let outputPipe = Pipe()
    task.launchPath = "/usr/local/bin/yabai"
    task.arguments = args
    task.standardOutput = outputPipe
    task.launch()
    task.waitUntilExit()
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(decoding: outputData, as: UTF8.self)
    return (task.terminationStatus, output)
}

func switchSpace(_ space: String) {
    yabai("-m", "space", "--focus", space)
}

func switchSpace(index: Int32) {
    switchSpace(String(index))
}

@discardableResult
func querySpaces() throws -> SpacesJson {
    let (_, output) = yabai("-m", "query", "--spaces")
    let jsonArray = try JSONSerialization.jsonObject(with: output.data(using: .utf8)!, options : .allowFragments) as! [Dictionary<String, Any>]
    return jsonArray
}

func getFocusedSpace(_ spaces: SpacesJson) -> Int32 {
    for space in spaces {
        guard let focused = space["focused"] as? Bool else {
            continue
        }
        guard let index = space["index"] as? Int32 else {
            continue
        }
        if focused {
            return index
        }
    }
    return -1
}
