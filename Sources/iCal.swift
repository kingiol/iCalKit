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

    // Content lines longer than 75 octets SHOULD be folded.
    // a text line in vcalendar can't exceed 75 chars, we choice 74, because we then add a space before line ahead.
    static fileprivate let maxLineChars = 74
    static public func normalize(cal: String) -> String {
        let icsContent = cal.components(separatedBy: "\n")
        var result = ""
        for line in icsContent {
            let subLine = line.split(byUTF8Length: maxLineChars).enumerated().compactMap({ $0 == 0 ? $1 : " " + $1 }).joined(separator: "\n")
            result += subLine + "\n"
        }
        return result
    }

}
