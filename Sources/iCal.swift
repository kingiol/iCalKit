import Foundation

public enum iCal {
    /// Loads the content of a given string.
    ///
    /// - Parameter string: string to load
    /// - Returns: List of containted `Calendar`s
    public static func load(string: String) -> [Calendar] {
        let icsContent = string.components(separatedBy: "\n")
        return parse(icsContent)
    }

    /// Loads the contents of a given URL. Be it from a local path or external resource.
    ///
    /// - Parameters:
    ///   - url: URL to load
    ///   - encoding: Encoding to use when reading data, defaults to UTF-8
    /// - Returns: List of contained `Calendar`s.
    /// - Throws: Error encountered during loading of URL or decoding of data.
    /// - Warning: This is a **synchronous** operation! Use `load(string:)` and fetch your data beforehand for async handling.
    public static func load(url: URL, encoding: String.Encoding = .utf8) throws -> [Calendar] {
        let data = try Data(contentsOf: url)
        guard let string = String(data: data, encoding: encoding) else { throw iCalError.encoding }
        return load(string: string)
    }

    private static func parse(_ icsContent: [String]) -> [Calendar] {
        let parser = Parser(icsContent + [""])
        do {
            return try parser.read()
        } catch let error {
            print(error)
            return []
        }
    }

    // a text line in vcalendar can't exceed 75 chars
    static fileprivate let maxLineChars = 75
    static public func normalize(cal: String) -> String {
        let icsContent = cal.components(separatedBy: "\n")
        var result = ""
        for line in icsContent {
            if line.utf8.count < maxLineChars {
                result += line + "\n";
                continue
            }
            var theLine = line
            var utf16Count = 20
            while theLine.count > utf16Count {
                let temp = String(theLine.prefix(utf16Count))
                if temp.utf8.count > maxLineChars - 5 {
                    if theLine.count != line.count { result += " " }
                    result += temp + "\n"
                    theLine.removeFirst(utf16Count)
                    utf16Count = 20
                } else {
                    utf16Count += 1
                }
            }
            
            if !theLine.isEmpty {
                if theLine.count != line.count { result += " " }
                result += theLine + "\n"
            }
        }
        return result
    }

}
