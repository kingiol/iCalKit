import Foundation

typealias TypeKeyAttribute = (type: String, attributes: [String: String])

extension String {
    /// TODO add documentation
    func toKeyValuePair(splittingOn separator: Character) -> (first: String, second: String)? {
        let arr = self.split(separator: separator,
                                        maxSplits: 1,
                                        omittingEmptySubsequences: false)
        if arr.count < 2 {
            return nil
        } else {
            return (String(arr[0]), String(arr[1]))
        }
    }

    /// Convert String to Date
    func toDate(withTZID tzid: String? = nil) -> Date? {
        return TZID.dateFormatter(forTZID: tzid).date(from: self)
    }

    func toShortDate() -> Date? {
        return TZID.shortDateFormatter.date(from: self)
    }

    func getIntNumber() -> [Int] {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap(Int.init)
    }

    func formatKeyAttribute() -> TypeKeyAttribute {
        let parts = split(separator: ";").map(String.init)
        var key = ""
        var attributes: [String: String] = [:]
        for part in parts {
            let keyV = part.split(separator: "=").map(String.init)
            if keyV.count < 2 && key.isEmpty {
                key = keyV[0]
            } else {
                attributes[keyV[0]] = keyV[1]
            }
        }
        return (key, attributes)
    }

}


/**
 *  - Event Date Key String extension
 */
extension String {

    func toEventDTDate(time: String?) -> Date? {
        guard let time = time else { return nil }
        let keyAttribute = formatKeyAttribute()
        if keyAttribute.attributes["VALUE"] == "DATE" {
            return time.toShortDate()
        } else if let tzid = keyAttribute.attributes["TZID"], !time.hasSuffix("Z") {
            return time.toDate(withTZID: tzid)
        } else {
            return time.toDate(withTZID: nil)
        }
    }

}
