import Foundation

/// TODO add documentation
public struct Event {
    public var subComponents: [CalendarComponent] = []
    public var otherAttrs = [String:String]()
    public var roles: [EventRole] = []

    // required
    public var uid: String?
    public var dtstamp: Date?

    // optional

    public var location: String? {
        get {
            guard let key = otherAttrs.filterKeyHasPrefix("LOCATION") else { return nil }
            return Parser.decode(value: otherAttrs[key])
        }
        set {
            guard let key = otherAttrs.filterKeyHasPrefix("LOCATION") else {
                otherAttrs["LOCATION"] = Parser.encode(value: newValue); return }
            otherAttrs[key] = Parser.encode(value: newValue)
        }
    }

    public var summary: String? {
        get {
            guard let key = otherAttrs.filterKeyHasPrefix("SUMMARY") else { return nil }
            return Parser.decode(value: otherAttrs[key])
        }
        set {
            guard let key = otherAttrs.filterKeyHasPrefix("SUMMARY") else {
                otherAttrs["SUMMARY"] = Parser.encode(value: newValue); return }
            otherAttrs[key] = Parser.encode(value: newValue)
        }
    }

    public var descr: String? {
        get {
            guard let key = otherAttrs.filterKeyHasPrefix("DESCRIPTION") else { return nil }
            return Parser.decode(value: otherAttrs[key])
        }
        set {
            guard let key = otherAttrs.filterKeyHasPrefix("DESCRIPTION") else {
                otherAttrs["DESCRIPTION"] = Parser.encode(value: newValue); return }
            otherAttrs[key] = Parser.encode(value: newValue)
        }
    }

    public var `class`: String?

    public var dtstart: Date? {
        get {
            guard let key = otherAttrs.filterKeyHasPrefix("DTSTART") else { return nil }
            return key.toEventDTDate(time: otherAttrs[key])
        }
        set {
            guard let key = otherAttrs.filterKeyHasPrefix("DTSTART") else {
                otherAttrs["DTSTART"] = newValue?.toUTCString(); return }
            otherAttrs[key] = newValue?.toDateString(forEventKey: key)
        }
    }

    public var dtend: Date? {
        get {
            guard let key = otherAttrs.filterKeyHasPrefix("DTEND") else { return nil }
            return key.toEventDTDate(time: otherAttrs[key])
        }
        set {
            guard let key = otherAttrs.filterKeyHasPrefix("DTEND") else {
                otherAttrs["DTEND"] = newValue?.toUTCString(); return }
            otherAttrs[key] = newValue?.toDateString(forEventKey: key)
        }
    }

    public var status: String?

    public init(uid: String? = NSUUID().uuidString, dtstamp: Date? = Date()) {
        self.uid = uid
        self.dtstamp = dtstamp
    }

    public func firstAlarm() -> Alarm? {
        return subComponents.compactMap({ $0 as? Alarm }).first
    }
}

extension Event: CalendarComponent {
    public func toCal() -> String {
        var str: String = "BEGIN:VEVENT\n"

        if let uid = uid {
            str += "UID:\(uid)\n"
        }
        if let cls = self.class {
            str += "CLASS:\(cls)\n"
        }
        if let dtstamp = dtstamp {
            str += "DTSTAMP:\(dtstamp.toUTCString())\n"
        }
//        if let summary = summary {
//            str += "SUMMARY:\(summary)\n"
//        }
//        if let location = location {
//            str += "LOCATION:\(location)\n"
//        }
//        if let descr = descr {
//            str += "DESCRIPTION:\(descr)\n"
//        }
//        if let dtstart = dtstart {
//            str += "DTSTART:\(dtstart.toString())\n"
//        }
//        if let dtend = dtend {
//            str += "DTEND:\(dtend.toString())\n"
//        }
        if let status = status {
            str += "STATUS:\(status)\n"
        }

        for role in roles {
            str += "\(role.toCal())\n"
        }

        for (key, val) in otherAttrs {
            str += "\(key):\(val)\n"
        }

        for component in subComponents {
            str += "\(component.toCal())\n"
        }

        str += "END:VEVENT"
        return str
    }
}

extension Event: IcsElement {
    public mutating func addAttribute(attr: String, _ value: String) {
        switch attr {
        case "UID":
            uid = value
        case "CLASS":
            self.class = value
        case "DTSTAMP":
            dtstamp = value.toDate()
//        case "DTSTART":
//            dtstart = value.toDate()
//        case "DTEND":
//            dtend = value.toDate()
        // case "ORGANIZER":
        //     organizer
//        case "SUMMARY":
//            summary = value
//        case "DESCRIPTION":
//            descr = value
        case "STATUS":
            status = value
//        case "LOCATION":
//            location = value
        case _ where attr.hasPrefix("ORGANIZER;"),
             _ where attr.hasPrefix("ATTENDEE;"):
            if let eventRole = EventRole.eventForm(key: attr, value: value) {
                roles.append(eventRole)
            }
        default:
            otherAttrs[attr] = value
        }
    }
}

extension Event: Equatable { }

public func ==(lhs: Event, rhs: Event) -> Bool {
    return lhs.uid == rhs.uid
}

extension Event: CustomStringConvertible {
    public var description: String {
        return "\(dtstamp?.toUTCString() ?? ""): \(summary ?? "")"
    }
}
