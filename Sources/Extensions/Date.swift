import Foundation

extension Date {
    /// Convert String to Date

    func toUTCString() -> String {
        return TZID.dateFormatter(forTZID: nil).string(from: self)
    }

    func toShortString() -> String {
        return TZID.shortDateFormatter.string(from: self)
    }
}

extension Date {

    func toDateString(forEventKey key: String) -> String {
        let keyAttribute = key.formatKeyAttribute()
        if keyAttribute.attributes["VALUE"] == "DATE" {
            return toShortString()
        } else if let tzid = keyAttribute.attributes["TZID"] {
            return TZID.dateFormatter(forTZID: tzid).string(from: self)
        } else {
            return toUTCString()
        }
    }

}
