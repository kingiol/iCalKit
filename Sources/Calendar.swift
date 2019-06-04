import Foundation

public enum CalendarMethod: String {
    case request = "REQUEST"
    case reply = "REPLY"
}

/// TODO add documentation
public struct Calendar {
    public var subComponents: [CalendarComponent] = []
    public var otherAttrs: [String: String] = [:]

    public typealias Attribute = (key: String, value: String)
    public var flowAttrs: [Attribute] = []

    public var method: CalendarMethod?
    public var prodid: String?
    public var version: String?

    public init(withComponents components: [CalendarComponent]?) {
        if let components = components {
            self.subComponents = components
        }
    }

    public func firstEvent() -> Event? {
        return subComponents.compactMap({ $0 as? Event }).first
    }

    public mutating func control(partStat: PartStat, forAddress address: String, newSummary: String? = nil, prodid: String = "-//Chirpeur Inc //Chirp Mail", version: String = "2.0") {
        method = .reply
        self.prodid = prodid
        self.version = version
        guard var event = firstEvent() else { return }
        let roles = event.roles.filter({ $0.partyType != .organizer && $0.mailto == address })
        var newRoles: [EventRole] = []
        if roles.isEmpty {
            let role = EventRole(partyType: .attendee, partStat: partStat, roleType: .opt, mailto: address)
            newRoles.append(role)
        } else {
            for var role in roles {
                role.partStat = partStat
                newRoles.append(role)
            }
        }

        let organizer = firstEvent()?.roles.filter({ $0.partyType == .organizer }) ?? []
        event.roles = organizer + newRoles
        if let summary = newSummary, !summary.isEmpty { event.summary = summary }

        event.descr = nil

        subComponents[0] = event
    }
}

extension Calendar: IcsElement {

    public mutating func append(component: CalendarComponent?) {
        guard let component = component else {
            return
        }
        self.subComponents.append(component)
    }

    public mutating func addAttribute(attr: String, _ value: String) {
        switch attr {
        case "METHOD":
            if let method = CalendarMethod(rawValue: value) {
                self.method = method
            } else {
//                otherAttrs[attr] = value
                flowAttrs.append((attr, value))
            }
        case "PRODID":
            self.prodid = value
        case "VERSION":
            self.version = value
        default:
//            otherAttrs[attr] = value
            flowAttrs.append((attr, value))
        }
    }

}

extension Calendar: CalendarComponent {
    public func toCal() -> String {
        var str = "BEGIN:VCALENDAR\n"

        if let method = method {
            str += "METHOD:\(method.rawValue)\n"
        }

        if let prodid = prodid {
            str += "PRODID:\(prodid)\n"
        }

        if let version = version {
            str += "VERSION:\(version)\n"
        }

        for (key, val) in otherAttrs {
            str += "\(key):\(val)\n"
        }

        for (key, val) in flowAttrs {
            str += "\(key):\(val)\n"
        }

        for component in subComponents {
            str += "\(component.toCal())\n"
        }

        str += "END:VCALENDAR\n"
        return iCal.normalize(cal: str)
    }
}
