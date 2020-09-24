//
//  LocationManager.swift
//  GoldenHour
//
//  https://adrianhall.github.io/swift/2019/11/05/swiftui-location/
//

import Foundation
import CoreLocation
import Combine

class Datastore: NSObject, ObservableObject {
    private     let locationManager  = CLLocationManager()
    private     let geocoder         = CLGeocoder()
                let objectWillChange = PassthroughSubject<Void, Never>()
    private     var liveLocation: Bool
    
    @Published  var status: CLAuthorizationStatus? {
        willSet { objectWillChange.send() }
    }
    
    @Published  var location: CLLocation? {
        willSet { objectWillChange.send() }
    }
    
    @Published  var placemark: CLPlacemark? {
        willSet { objectWillChange.send() }
    }
    
                var latitude:   Double?
                var longitude:  Double?
    
                var jdFrom:     Double
                var jdTo:       Double
    
    @Published  var golden:     Array<(String, String)>
    @Published  var blue:       Array<(String, String)>
                var goldenJD:   Array<(Double?, Double?)>?
                var blueJD:     Array<(Double?, Double?)>?
    @Published  var sunriseSunset: Array<(Double?, Double?)>?
    @Published  var sunrise:    String
    @Published  var sunset:     String
    @Published  var localDate:  String
    
    @Published  var formatter:      DateFormatter
                var dateFormatter:  DateFormatter
    
    override init() {
        self.liveLocation = true
        
        self.jdFrom = jdFromDate(date: lastMidnight()! as NSDate)
        self.jdTo = jdFromDate(date: NSDate.init(timeInterval: 24*3600, since: lastMidnight()!))
        self.formatter = DateFormatter()
        self.dateFormatter = DateFormatter()
        self.blue = [("–", "–"), ("–", "–")]
        self.golden = [("–", "–"), ("–", "–")]
        self.sunrise = "–"
        self.sunset = "–"
        self.localDate = ".."
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.formatter.timeZone = .current
        self.formatter.dateFormat = "HH:mm"
        self.dateFormatter.dateFormat = "dd.MM.yyyy"
    }
    
    private func geocode() {
        // @TODO: Berre oppdater viss noko informasjon manglar OG plassen er endra med meir enn 1 breidde/lengdegrad
        guard let location = self.location else { return }
        geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
            if error == nil {
                self.placemark = places?[0]
                self.formatter.timeZone = self.placemark?.timeZone
            } else {
                self.placemark = nil
            }
        })
        // Update timezone with placemark timezone
        // https://developer.apple.com/documentation/corelocation/clplacemark
        print("New location: \(self.location)")
        print("New placemark: \(self.placemark?.name ?? "–") with timezone: \(String(describing: self.placemark?.timeZone?.secondsFromGMT()))")
        
        self.updateHours()
    }
    
    private func updateHours() {
        self.latitude = self.location?.coordinate.latitude ?? 0
        self.longitude = self.location?.coordinate.longitude ?? 0
        
        let localmidnight = lastMidnight(timeZone: self.placemark?.timeZone ?? .current)! as NSDate
        self.jdFrom = jdFromDate(date: localmidnight)
        self.jdTo   = self.jdFrom + 1
        self.localDate = self.dateFormatter.string(from: localmidnight as Date)
        
        self.goldenJD = findRange(lat: self.latitude!, long: self.longitude!, start: self.jdFrom, stop: self.jdTo, bottom: -6.0, top: 6.0)
        self.blueJD = findRange(lat: self.latitude!, long: self.longitude!, start: self.jdFrom, stop: self.jdTo, bottom: -10.0, top: -6.0)
        self.sunriseSunset = findRange(lat: self.latitude!, long: self.longitude!, start: self.jdFrom, stop: self.jdTo, bottom: -1.0, top: 100.0)
        self.golden = []
        for sequence in self.goldenJD! {
            var start = "–"
            var stop = "–"
            if sequence.0 != nil {
                start = self.formatter.string(from: dateFromJd(jd: sequence.0!) as Date)
            }
            if sequence.1 != nil {
                stop = self.formatter.string(from: dateFromJd(jd: sequence.1!) as Date)
            }
            self.golden.append((start, stop))
        }
        self.blue = []
        for sequence in self.blueJD! {
            var start = "–"
            var stop = "–"
            if sequence.0 != nil {
                start = self.formatter.string(from: dateFromJd(jd: sequence.0!) as Date)
            }
            if sequence.1 != nil {
                stop = self.formatter.string(from: dateFromJd(jd: sequence.1!) as Date)
            }
            self.blue.append((start, stop))
        }
        
        if self.sunriseSunset![0].0 == nil {
            self.sunrise = "–"
        } else {
            self.sunrise = self.formatter.string(from: dateFromJd(jd: sunriseSunset![0].0!) as Date)
        }
        if self.sunriseSunset![0].1 == nil {
            self.sunset = "–"
        } else {
            self.sunset = self.formatter.string(from: dateFromJd(jd: sunriseSunset![0].1!) as Date)
        }
        
        print("JD: \(self.jdFrom) – \(self.jdTo)")
        print("Sunrise: \(self.sunrise), sunset: \(self.sunset)")
    }
}

extension Datastore: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.geocode()
    }
}
