//
//  LocationManager.swift
//  GoldenHour
//
//  https://adrianhall.github.io/swift/2019/11/05/swiftui-location/
//

import Foundation
import CoreLocation
import Intents
import Contacts
import Combine
import SwiftUI
//import CoreData

class Datastore: NSObject, ObservableObject {
    private     let locationManager  = CLLocationManager()
    private     let geocoder         = CLGeocoder()
                let objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published  var status: CLAuthorizationStatus? {
        willSet { objectWillChange.send() }
    }
    @Published  var liveLocation: CLLocation? {
        willSet { objectWillChange.send() }
    }
    @Published  var placemark: CLPlacemark? {
        willSet { objectWillChange.send() }
    }
    
    @Published  var isLocationLive:   Bool
//    @State      var showPicker:     Bool = false
    @Published  var locationId:     UUID?
                var selectedLocation: CLLocation?
//    @FetchRequest(entity: Place.entity(), sortDescriptors: []) var places: FetchedResults<Place>
    @Environment(\.managedObjectContext) var moc
    
                var latitude:   Double?
                var longitude:  Double?
    @Published  var locationString: String
    
                var jdFrom:     Date
                var jdTo:       Date
    
    @Published  var golden:     Array<(String, String)>
    @Published  var blue:       Array<(String, String)>
                var goldenJD:   Array<(Double?, Double?)>?
                var blueJD:     Array<(Double?, Double?)>?
    @Published  var sunriseSunset: Array<(Double?, Double?)>?
    @Published  var sunrise:    String
    @Published  var sunset:     String
    @Published  var localDateString:  String
    @Published  var localDate:  Date {
        didSet(newValue) {
            print(newValue)
            self.geocode()
        }
    }
    
//    private var dateProxy:Binding<Date> {
//        Binding<Date>(get: {self.date }, set: {
//            self.date = $0
//            self.updateWeekAndDayFromDate()
//        })
//    }
    
    @Published  var formatter:      DateFormatter
                var dateFormatter:  DateFormatter
    
    override init() {
        self.isLocationLive = true
        self.locationString = ""
        
        self.localDate = Date()
        self.jdFrom = lastMidnight()!
        self.jdTo = Date(timeInterval: 24*3600, since: self.jdFrom)
        self.formatter = DateFormatter()
        self.dateFormatter = DateFormatter()
        self.blue = [("–", "–"), ("–", "–")]
        self.golden = [("–", "–"), ("–", "–")]
        self.sunrise = "–"
        self.sunset = "–"
        self.localDateString = ".."
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.formatter.timeZone = .current
        self.formatter.dateFormat = "HH:mm"
        self.dateFormatter.dateFormat = "dd.MM.yyyy"
        
//        print(self.places)
    }
    
    private func geocode() {
        // @TODO: Berre oppdater viss noko informasjon manglar OG plassen er endra med meir enn 1 breidde/lengdegrad
        guard let location = self.liveLocation else { return }
        geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
            print("\(#line) \(places)")
            if error == nil {
                self.placemark = places?[0]
                
                self.formatter.timeZone = self.placemark?.timeZone
                print("New location: \(self.liveLocation == nil ? "–" : String(describing: self.liveLocation!.coordinate))")
                print("New placemark: \(self.placemark?.name ?? "–") with timezone: \(String(describing: self.placemark?.timeZone?.secondsFromGMT()))")
                
                if self.isLocationLive == true {
                    self.updateVisibleLocation()
                    self.updateHours()
                }
                
            } else {
                self.placemark = nil
            }
        })
        
    }
    
    func setLocation(to place: Place) {
        /// Manuell lokasjonssetjing
        print("Set lokasjon til \(String(describing: place.name))")
        self.isLocationLive = false
        
        let temporaryLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        self.selectedLocation = temporaryLocation
//        self.placemark = CLPlacemark(location: temporaryLocation, name: place.name, postalAddress: nil)
        self.formatter.timeZone = TimeZone(secondsFromGMT: Int(place.gmtOffset))
        
        self.updateVisibleLocation(with: place.name)
        self.updateHours()
    }
    
    func autolocate() {
        print("\(#line) self.isLocationLive = true")
        self.isLocationLive = true
        self.geocode()
    }
    
    func updateVisibleLocation(with name: String? = nil) {
        var locationString: String
        let latitude: Double
        let longitude: Double
        
        if self.isLocationLive == true {
            locationString = "\(self.placemark?.name ?? "–")\n"//", \(place!.countryCode)\n"
            latitude = self.liveLocation?.coordinate.latitude ?? 0.0
            longitude = self.liveLocation?.coordinate.longitude ?? 0.0
        } else {
            locationString = "\(name!)\n"
            latitude = self.selectedLocation?.coordinate.latitude ?? 0
            longitude = self.selectedLocation?.coordinate.longitude ?? 0
        }
        
        if latitude < 0 {
            locationString += "\(-latitude) S, "
        } else {
            locationString += "\(latitude) N, "
        }
        if longitude < 0 {
            locationString += "\(-longitude) V"
        } else {
            locationString += "\(longitude) A"
        }
        self.locationString = locationString
    }
    
    private func updateHours() {
        let localMidnight: Date
        if self.isLocationLive == true {
            print("Datastore:\(#line) Oppdaterer dato med live lokasjon")
            self.latitude = self.liveLocation?.coordinate.latitude ?? 0
            self.longitude = self.liveLocation?.coordinate.longitude ?? 0
            localMidnight = lastMidnight(timeZone: self.placemark?.timeZone ?? .current, localTime: self.localDate)!
        } else {
            print("Datastore:\(#line) Oppdaterer dato med valt lokasjon")
            self.latitude = self.selectedLocation?.coordinate.latitude ?? 0
            self.longitude = self.selectedLocation?.coordinate.longitude ?? 0
            localMidnight = lastMidnight(timeZone: self.formatter.timeZone, localTime: self.localDate)!
        }
        
        self.jdFrom = localMidnight
        self.jdTo   = self.jdFrom + 24*3600
        self.localDateString = self.dateFormatter.string(from: localMidnight)
        
        self.goldenJD = findRange(lat: self.latitude!, long: self.longitude!, start: self.jdFrom, stop: self.jdTo, bottom: -6.0, top: 6.0)
        self.blueJD = findRange(lat: self.latitude!, long: self.longitude!, start: self.jdFrom, stop: self.jdTo, bottom: -10.0, top: -6.0)
        self.sunriseSunset = findRange(lat: self.latitude!, long: self.longitude!, start: self.jdFrom, stop: self.jdTo, bottom: -0.0, top: 100.0)
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
        self.liveLocation = location
        self.geocode()
    }
}
