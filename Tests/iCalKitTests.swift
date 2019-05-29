//
//  iCalTests.swift
//  iCal
//
//  Created by Kilian Koeltzsch on {TODAY}.
//  Copyright © 2017 iCal. All rights reserved.
//

import XCTest
@testable import iCalKit

class iCalTests: XCTestCase {
    static var allTests = [
        ("testLoadLocalFile", testLoadLocalFile),
        ("testEventData", testEventData),
        ("testQuickstart", testQuickstart),
        ("testQuickstartFromUrl", testQuickstartFromUrl),
    ]

    var exampleCals: [iCalKit.Calendar] = []

    override func setUp() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "example", withExtension: "ics") else {
            XCTAssert(false, "no test ics file")
            return
        }
        
        do {
            self.exampleCals = try iCal.load(url: url)
        } catch {
            print(error.localizedDescription)
        }
    }

    func testLoadLocalFile() {
        XCTAssert(exampleCals.count > 0)
    }

    func testEventData() {
        guard let cal = exampleCals.first
            else {
                XCTAssert(false, "No calendar found")
                return
        }

        var firstEvent: Event = Event()
        firstEvent.uid = "uid1@example.com"
        firstEvent.dtstamp = "19970714T170000Z".toDate()
        firstEvent.summary = "Bastille Day Party"
        firstEvent.dtstart = "19970714T170000Z".toDate()
        firstEvent.dtend = "19970715T035959Z".toDate()
        // TODO add alarm to `firstEvent`

        var secondEvent: Event = Event()
        secondEvent.uid = "uid2@example.com"
        secondEvent.dtstamp = "19980714T170000Z".toDate()
        secondEvent.summary = "Something completely different"
        secondEvent.dtstart = "19980714T170000Z".toDate()
        secondEvent.dtend = "19980715T035959Z".toDate()
        // TODO add organizer to `secondEvent`

        XCTAssertEqual(cal.subComponents.count, 2) // Should have 2 events
        XCTAssertEqual(cal.subComponents[0] as! Event, firstEvent)
        XCTAssertEqual(cal.subComponents[1] as! Event, secondEvent)
    }

    func testQuickstart() {
        var event = Event()
        event.summary = "Awesome event"
        let calendar = Calendar(withComponents: [event])
        let iCalString = calendar.toCal()

        XCTAssertEqual(iCalString.contains("SUMMARY:Awesome event"), true)
    }

    func testQuickstartFromUrl() {
        let url = URL(string: "https://raw.githubusercontent.com/kiliankoe/iCalKit/master/Tests/example.ics")!
        let cals = try! iCal.load(url: url)
        // or loadFile() or loadString(), all of which return [Calendar] as an ics file can contain multiple calendars

        for cal in cals {
            for event in cal.subComponents where event is Event {
                print(event)
            }
        }

        XCTAssertEqual(cals.count, 1)
        XCTAssertEqual(cals[0].subComponents.count, 2) // Should have 2 events
        XCTAssertEqual("\(cals[0].subComponents[0])", "19970714T170000Z: Bastille Day Party")
        XCTAssertEqual("\(cals[0].subComponents[1])", "19980714T170000Z: Something completely different")
    }

    func testQuickstartFromString() {
        let ics = """
BEGIN:VCALENDAR
METHOD:REQUEST
PRODID:Microsoft Exchange Server 2010
VERSION:2.0
BEGIN:VTIMEZONE
TZID:China Standard Time
BEGIN:STANDARD
DTSTART:16010101T000000
TZOFFSETFROM:+0800
TZOFFSETTO:+0800
END:STANDARD
BEGIN:DAYLIGHT
DTSTART:16010101T000000
TZOFFSETFROM:+0800
TZOFFSETTO:+0800
END:DAYLIGHT
END:VTIMEZONE
BEGIN:VEVENT
ORGANIZER;CN=S Sam:MAILTO:sugarmail@msn.comATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN=hi.sugar@163.com:MAILTO:hi.sugar@163.com
ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN=Jimmy S:MAILTO:jimmys@chirpeur.com
ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN=jimmys@yeetalk.net:MAILTO:jimmys@yeetalk.net
DESCRIPTION;LANGUAGE=en-US:For larger customers with special requirements we also have enterprise plans starting at $1,000/mo with custom tiers, data isolation, on-premise support and annual invoicing.
UID:040000008200E00074C5B7101A82E00800000000307A017EFB15D501000000000000000
01000000010E8F5EDEFB7054797B55B075E7EEA1F
SUMMARY;LANGUAGE=en-US:Try Ghost free for 14 days
DTSTART;VALUE=DATE:20190530
DTEND;VALUE=DATE:20190602
CLASS:PUBLIC
PRIORITY:5
DTSTAMP:20190529T084957Z
TRANSP:TRANSPARENT
STATUS:CONFIRMED
SEQUENCE:0
LOCATION;LANGUAGE=en-US:中兴和泰酒店 (科苑路866号, Shanghai 上海市, China)
X-MICROSOFT-CDO-APPT-SEQUENCE:0
X-MICROSOFT-CDO-OWNERAPPTID:2117463856
X-MICROSOFT-CDO-BUSYSTATUS:FREE
X-MICROSOFT-CDO-INTENDEDSTATUS:FREE
X-MICROSOFT-CDO-ALLDAYEVENT:TRUE
X-MICROSOFT-CDO-IMPORTANCE:1
X-MICROSOFT-CDO-INSTTYPE:0
X-MICROSOFT-DONOTFORWARDMEETING:FALSE
X-MICROSOFT-DISALLOW-COUNTER:FALSE
X-MICROSOFT-LOCATIONDISPLAYNAME:中兴和泰酒店
X-MICROSOFT-LOCATIONSOURCE:None
X-MICROSOFT-LATITUDE:31.1972
X-MICROSOFT-LONGITUDE:121.589
X-MICROSOFT-LOCATIONSTREET:科苑路866号
X-MICROSOFT-LOCATIONCITY:Shanghai
X-MICROSOFT-LOCATIONSTATE:上海市
X-MICROSOFT-LOCATIONCOUNTRY:China
X-MICROSOFT-LOCATIONS:[{"DisplayName":"中兴和泰酒店","LocationAnnotation":"","LocationUri":"","Latitude":31.1972,"Longitude":121.589,"LocationStreet":"科苑路866号","LocationCity":"Shanghai","LocationState":"上海市","LocationCountry":"China","LocationPostalCode":"","LocationFullAddress":""}]
BEGIN:VALARM
DESCRIPTION:REMINDER
TRIGGER;RELATED=START:-P1D
ACTION:DISPLAY
END:VALARM
END:VEVENT
END:VCALENDAR
"""

        let icals = try! iCal.load(string: ics)
        let event = icals.first?.firstEvent()
        print("...")
    }
}
