//
//  TZID.swift
//  iCalKit
//
//  Created by Kingiol on 2019/5/30.
//  Copyright © 2019 iCalKit. All rights reserved.
//

import Foundation

class TZID {

    static let shortDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }()

    private static let dateFormatter: DateFormatter = {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return dateformatter
    }()

    class func timeZone(forTZID tzid: String) -> TimeZone {
        let knownIdentifiers = TimeZone.knownTimeZoneIdentifiers

        if knownIdentifiers.contains(tzid) {
            return TimeZone(identifier: tzid) ?? TimeZone.current
        }

        for identifier in knownIdentifiers {
            guard let timeZone = TimeZone(identifier: identifier) else { continue }
            let standTimeName = timeZone.localizedName(for: .standard, locale: Locale(identifier: "en_US"))
            if tzid == standTimeName {
                return timeZone
            }
        }

        return TimeZone.current
    }

    class func dateFormatter(forTZID tzid: String? = nil) -> DateFormatter {
        let timeZone: TimeZone?
        if let tzid = tzid {
            timeZone = TZID.timeZone(forTZID: tzid)
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        } else {
            timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        }
        dateFormatter.timeZone = timeZone
        return dateFormatter
    }

}
