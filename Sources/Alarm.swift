import Foundation

public enum AlarmTrigger {

    case minutes(number: Int)
    case hours(number: Int)
    case days(number: Int)

}

extension AlarmTrigger: CalendarComponent {
    public func toCal() -> String {
        var str = "TRIGGER;VALUE=DURATION:-P"
        switch self {
        case let .minutes(number):
            str += "T\(number)M"
        case let .hours(number):
            str += "T\(number)H"
        case let .days(number):
            str += "\(number)D"
        }
        return str
    }
}

/// TODO add documentation
public struct Alarm {
    public var subComponents: [CalendarComponent] = []
    public var otherAttrs = [String:String]()

    public var trigger: AlarmTrigger?

}

extension Alarm: IcsElement {
    public mutating func addAttribute(attr: String, _ value: String) {
        switch attr {
        case _ where attr.hasPrefix("TRIGGER;"):
            if let indi = value.last.map(String.init)?.lowercased(), let number = value.getIntNumber().first {
                if indi == "M".lowercased() {
                    trigger = AlarmTrigger.minutes(number: number)
                } else if indi == "H".lowercased() {
                    trigger = AlarmTrigger.hours(number: number)
                } else if indi == "D".lowercased() {
                    trigger = AlarmTrigger.days(number: number)
                } else {
                    otherAttrs[attr] = value
                }
            } else {
                otherAttrs[attr] = value
            }
        default:
            otherAttrs[attr] = value
        }
    }
}

extension Alarm: CalendarComponent {
    public func toCal() -> String {
        var str = "BEGIN:VALARM\n"

        if let trigger = trigger {
            str += "\(trigger.toCal())\n"
        }

        for (key, val) in otherAttrs {
            str += "\(key):\(val)\n"
        }

        str += "END:VALARM"
        return str
    }
}
