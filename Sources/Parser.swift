import Foundation

/// TODO add documentation
internal class Parser {
    let icsContent: [String]

    init(_ ics: [String]) {
        icsContent = ics
    }

    func read() throws -> [Calendar] {
        var completeCal = [Calendar?]()

        // Such state, much wow
        var inCalendar = false
        var currentCalendar: Calendar?
        var inEvent = false
        var currentEvent: Event?
        var inAlarm = false
        var currentAlarm: Alarm?

        var previousLine = ""
        for (index, rawLine) in icsContent.enumerated() {
            let currentLine = rawLine.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            var progressLine: String = ""

            if !currentLine.isEmpty {
                if rawLine.hasPrefix(" ") {
                    previousLine += currentLine
                } else {
                    if !previousLine.isEmpty {
                        progressLine = previousLine
                    }
                    previousLine = currentLine
                }
            }

            if index == icsContent.count - 1 && !previousLine.isEmpty {
                progressLine = previousLine
            }
            guard !progressLine.isEmpty else { continue }

            switch progressLine {
            case "BEGIN:VCALENDAR":
                inCalendar = true
                currentCalendar = Calendar(withComponents: nil)
                continue
            case "END:VCALENDAR":
                inCalendar = false
                completeCal.append(currentCalendar)
                currentCalendar = nil
                continue
            case "BEGIN:VEVENT":
                inEvent = true
                currentEvent = Event()
                continue
            case "END:VEVENT":
                inEvent = false
                currentCalendar?.append(component: currentEvent)
                currentEvent = nil
                continue
            case "BEGIN:VALARM":
                inAlarm = true
                currentAlarm = Alarm()
                continue
            case "END:VALARM":
                inAlarm = false
                currentEvent?.append(component: currentAlarm)
                currentAlarm = nil
                continue
            default:
                break
            }

            guard let (key, value) = progressLine.toKeyValuePair(splittingOn: ":") else {
//                print("(key, value): line: \(line) is nil") // DEBUG
                continue
            }

            if inCalendar && !inEvent {
                currentCalendar?.addAttribute(attr: key, value)
            }

            if inEvent && !inAlarm {
                currentEvent?.addAttribute(attr: key, value)
            }

            if inAlarm {
                currentAlarm?.addAttribute(attr: key, value)
            }
        }

        return completeCal.compactMap{ $0 }
    }
    
    static private func doEncodeDecode(value: String?, maps: [String: String]) -> String? {
        guard var result = value else { return nil }
        for (from, to) in maps {
            result = result.replacingOccurrences(of: from, with: to)
        }
        return result
    }
    
    // RFC: ctls ; : , "
    static func decode(value: String?) -> String? {
        let maps = ["\\r": "\r", "\\n": "\n", "\\;": ";", "\\:": ":", "\\,": ",", "\\\"": "\""]
        return doEncodeDecode(value: value, maps: maps)
    }
    
    static func encode(value: String?) -> String? {
        let maps = ["\r": "\\r", "\n": "\\n", ";": "\\;", ":": "\\:", ",": "\\,", "\"": "\\\""]
        return doEncodeDecode(value: value, maps: maps)
    }
    
}
