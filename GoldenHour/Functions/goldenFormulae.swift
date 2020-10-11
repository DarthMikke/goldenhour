//
//  GoldenFormulae.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 18/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import Foundation

func elevation(lat: Double, long: Double, jd: Double) -> Double {
    let LAT = lat
    let LONG = long

//    let d2 = datetime.rounded(.towardZero)    // Dato
//    let e2 = datetime.truncatingRemainder(dividingBy: 1)     // Tid som andel av døgnet
//    let f2 = d2 + 2415018.5 + e2    // JD
    let f2 = jd
    let e2 = (jd - 2415018.5).truncatingRemainder(dividingBy: 1.0)
    let g2 = (f2-2451545.0)/36525.0     // Juliansk hundreår
    let g22 = g2*(36000.76983 + g2*0.0003032)
    let i2 = (280.46646 + g22).truncatingRemainder(dividingBy: 360.0) // Solas posisjon i ekliptikken, gradar
    let j2 = 357.52911 + g2*(35999.04029-0.0001537*g2) // Solas gjennomsnittlege anomali
//    let k2 = 0.016708634 - g2*(0.000042037+0.0000001267*g2) // Ekssentrisitet av jordas bane
    let l2 = sin(rad(j2))*(1.914602-g2*(0.004817+0.000014*g2)) + sin(rad(2*j2))*(0.0199993-0.000101*g2)+sin(rad(3*j2))*0.000289 // Sun Eq of Ctr
    let m2 = i2+l2 // Solas ekte posisjon i ekliptikken, gradar
//    let n2 = j2+l2 //
    let p2 = m2-0.00569-0.00478*sin(rad(125.04-1934.136*g2))
    let q2 = 23+(26+((21.448-g2*(46.815+g2*(0.00059-g2*0.001813))))/60)/60
    let r2 = q2 + 0.00256*cos(rad(125.04-1934.136*g2))
    let t2 = deg(asin(sin(rad(r2))*sin(rad(p2)))) // Deklinasjon, gradar
    let v2 = 0.0 // Tidslikning, minutt, 1–2 minutt, avhenger av i2, j2, k2, u2
    let ab21 = e2*1440.0 + v2
    let ab22 = 4.0*LONG
    let ab2 = (ab21 + ab22).truncatingRemainder(dividingBy: 1440) // Ekte soltid, minutt [0–1440]
    let ac2: Double
    if ab2/4.0 < 0 {
        ac2 = ab2/4.0+180
    } else {
        ac2 = ab2/4.0-180
    }
    let ad2 = deg (acos( sin(rad(LAT)) * sin(rad(t2)) + cos(rad(LAT)) * cos(rad(t2)) * cos(rad(ac2))))

    let elevation = 90-ad2 // Høgda til sola over horisonten
    
//    print(datetime, d2, e2, f2, g2)
    
    return elevation
}

func findRange(lat: Double, long: Double, start: Date, stop: Date, bottom: Double, top: Double) -> Array<(Double, Double)> {
    
    let startTime = DispatchTime.now()
    var array: [(Double, Double)] = []
    
    let step = 1.0/60/24 // JD
    var timeIn = 0.0
    var timeOut = 0.0
    var lastelev = -99.0
    var jd = jdFromDate(date: start as NSDate)
    let stop = jdFromDate(date: stop as NSDate)

    while jd < stop {
        let elev = elevation(lat: lat, long: long, jd: jd)
        if abs(lastelev - elev) > 8 {
            lastelev = elev
            jd += step
            continue
        }
        
        if (lastelev < bottom && elev >= bottom) || (lastelev > top && elev <= top) {
            timeIn = jd
        }
        else if (lastelev < top && elev >= top) || (lastelev > bottom && elev <= bottom) {
            timeOut = jd
            array.append((timeIn, timeOut))
        }
        lastelev = elev
        jd += step
    }

    if timeIn != 0 && timeOut == 0 {
        array.append((timeIn, timeOut))
    }
    
    let endTime = DispatchTime.now()
    #if DEBUG
    print("\(#function):\(#line) \((endTime.uptimeNanoseconds - startTime.uptimeNanoseconds)/1000000000) sekund")
    #endif
    return array
}

func lastMidnight(timeZone: TimeZone = .current) -> Date? {
    let dateOnly = DateFormatter()
    dateOnly.timeZone = timeZone
    dateOnly.dateFormat = "dd.MM.yyyy"
    
    let nowdate = Date()
    let start = dateOnly.date(from: dateOnly.string(from: nowdate))
    
    return start
}

func lastMidnight(timeZone: TimeZone = .current, localTime: Date = Date()) -> Date? {
    let dateOnly = DateFormatter()
    dateOnly.timeZone = timeZone
    dateOnly.dateFormat = "dd.MM.yyyy"
    
    let nowdate = localTime
    let start = dateOnly.date(from: dateOnly.string(from: nowdate))
    
    return start
}
