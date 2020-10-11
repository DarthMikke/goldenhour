// Attributed to https://github.com/eienf/
// Downloaded from https://gist.github.com/eienf/ed9a62f3935318711ef824a173b5375a

import Foundation

func jdFromDate(date : NSDate) -> Double {
    let JD_JAN_1_1970_0000GMT = 2440587.5
    return JD_JAN_1_1970_0000GMT + date.timeIntervalSince1970 / 86400
}

func dateFromJd(jd : Double) -> NSDate {
    let JD_JAN_1_1970_0000GMT = 2440587.5
    return  NSDate(timeIntervalSince1970: (jd - JD_JAN_1_1970_0000GMT) * 86400)
}

func date(year: Int, month: Int, day: Int) -> NSDate {
    let comps = NSDateComponents()
    comps.year = year
    comps.month = month
    comps.day = day
    comps.hour = 12
    let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
    let date = gregorian?.date(from: comps as DateComponents)
    return date! as NSDate
}
