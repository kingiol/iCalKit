//
//  EventRole.swift
//  iCalKit-iOS
//
//  Created by Kingiol on 2019/5/20.
//  Copyright © 2019 iCalKit. All rights reserved.
//

import Foundation

public enum PartyType: String {
    case organizer = "ORGANIZER"
    case attendee = "ATTENDEE"
}

public enum PartStat: String {
    case accepted = "ACCEPTED"  // accept
    case tentative = "TENTATIVE"    // maybe
    case declined = "DECLINED"  // declined
    case needsAction = "NEEDS-ACTION"
}

public enum RoleType: String {
    case chair = "CHAIR"
    case req = "REQ-PARTICIPANT"
    case opt = "OPT-PARTICIPANT"
}

public struct EventRole {

    public var partyType: PartyType
    public var partStat: PartStat?
    public var roleType: RoleType?
    public var mailto: String

    static func eventForm(key: String, value: String) -> EventRole? {
        let roles = key.split(separator: ";").map(String.init)
        guard let part = roles.first, let partType = PartyType(rawValue: part) else { return nil }
        _ = roles.dropFirst()

        var partStat: PartStat?
        var roleType: RoleType?

        for item in roles {
            let parts = item.split(separator: "=").map(String.init)
            let k = parts.first ?? ""
            let v = parts.last ?? ""
            if k == "PARTSTAT" {
                partStat = PartStat(rawValue: v)
            } else if k == "ROLE" {
                roleType = RoleType(rawValue: v)
            }
        }

        let mailtos = value.split(separator: ":").map(String.init)
        let address = mailtos.last?.trimmingCharacters(in: .whitespaces) ?? ""
        return EventRole(partyType: partType, partStat: partStat, roleType: roleType, mailto: address)
    }

}

extension EventRole: CalendarComponent {

    public func toCal() -> String {
        var str = "\(partyType.rawValue);"

        if let partStat = partStat {
            str += "PARTSTAT=\(partStat.rawValue);"
        }

        if let roleType = roleType {
            str += "ROLE=\(roleType.rawValue)"
        }

        str += ":mailto:\(mailto)"

        return str
    }

}
