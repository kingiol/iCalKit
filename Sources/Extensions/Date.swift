import Foundation

extension Date {
    /// Convert String to Date
    func toString() -> String {
        return iCal.dateFormatter.string(from: self)
    }

    func toShortString() -> String {
        return iCal.shortDateFormatter.string(from: self)
    }
}
