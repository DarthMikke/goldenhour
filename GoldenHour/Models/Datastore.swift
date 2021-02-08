//
//  LocationManager.swift
//  GoldenHour
//
//  Based on https://adrianhall.github.io/swift/2019/11/05/swiftui-location/
//

import Foundation
import CoreLocation
import Intents
import Contacts
import Combine
import SwiftUI
//import CoreData

struct sunTimes {
    var goldenJD:   Array<(Double?, Double?)>
    var blueJD:     Array<(Double?, Double?)>
    var sunrise:    Double?
    var sunset:     Double?
}

class Datastore: NSObject, ObservableObject {
//    @FetchRequest(entity: Place.entity(), sortDescriptors: []) var places: FetchedResults<Place>
    @Environment(\.managedObjectContext) var moc
    
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
    
    private     var numberFormatter: NumberFormatter
    @Published  var formatter:      DateFormatter
                var dateFormatter:  DateFormatter
    
    @Published  var isLocationLive:   Bool
    @Published  var locationId:     UUID?
    @Published  var selectedLocation: CLLocation?
    private     var selectedLocationName: String?
    
    private     var latitude:   Double?
    private     var longitude:  Double?
    @Published  var locationString: String
    
    private     var fromDate:     Date
    private     var toDate:       Date
    
    @Published  var golden:     Array<(String, String)>
    @Published  var blue:       Array<(String, String)>
    private     var goldenJD:   Array<(Double?, Double?)>?
    private     var blueJD:     Array<(Double?, Double?)>?
    private     var sunriseSunset: Array<(Double?, Double?)>?
    @Published  var sunrise:    String
    @Published  var sunset:     String
    @Published  var localDateString:  String
    @Published  var localDate:  Date {
        didSet(newValue) {
            print("Datastore:\(#line) Ny dato: \(newValue)")
            self.geocode()
//            self.updateVisibleLocation()
        }
    }
    
//    private var dateProxy:Binding<Date> {
//        Binding<Date>(get: {self.date }, set: {
//            self.date = $0
//            self.updateWeekAndDayFromDate()
//        })
//    }
    
    
    override init() {
        self.isLocationLive = true
        self.locationString = "Finn posisjon…\n"
        
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
        self.numberFormatter.maximumFractionDigits = 2
        
        self.localDate = Date()
        self.fromDate = lastMidnight()!
        self.toDate = Date(timeInterval: 24*3600, since: self.fromDate)
        self.formatter = DateFormatter()
        self.dateFormatter = DateFormatter()
        self.blue = [("–", "–"), ("–", "–")]
        self.golden = [("–", "–"), ("–", "–")]
        self.sunrise = "–"
        self.sunset = "–"
        self.localDateString = ".."
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.formatter.timeZone = .current
        self.formatter.dateFormat = "HH:mm"
        self.dateFormatter.dateFormat = "dd.MM.yyyy"
        
//        print(self.places)
    }
    
    private func geocode() {
        // @TODO: Oppdater dato og manuell stad sjølv om det er for dåleg dekning for ei smidig oppleving med "completionHandler"
        guard let location = self.liveLocation else { return }
        geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
            print("Datastore:\(#line) \(String(describing: places))")
            if error == nil {
                self.placemark = places?[0]
                
                print("Datastore:\(#line) New location: \(self.liveLocation == nil ? "–" : String(describing: self.liveLocation!.coordinate))")
                print("Datastore:\(#line) New placemark: \(self.placemark?.name ?? "–") with timezone: \(String(describing: self.placemark?.timeZone?.secondsFromGMT()))")
                
                if self.isLocationLive == true { // @TODO: Flytt det her ut av "completionHandler"
                    self.formatter.timeZone = self.placemark?.timeZone
                }// else {
                    self.updateVisibleLocation()
                    self.updateHours()
//                }
                self.locationManager.stopUpdatingLocation()
            } else {
                self.placemark = nil
            }
        })
    }
    
    func setLocation(to place: Place) {
        /// Manuell lokasjonssetjing. Oppdaterer plass fyrst, så tidspunkt
        print("Datastore:\(#line) Set lokasjon til \(String(describing: place.name))")
        self.isLocationLive = false
        
        ///#Oppdater plass
        self.selectedLocationName = place.name
        let temporaryLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        self.selectedLocation = temporaryLocation
        self.updateVisibleLocation()
//        self.placemark = CLPlacemark(location: temporaryLocation, name: place.name, postalAddress: nil)
        
        ///#Oppdater tidspunkt
        self.formatter.timeZone = TimeZone(secondsFromGMT: Int(place.gmtOffset))
        self.dateFormatter.timeZone = self.formatter.timeZone
        self.geocode()
        self.updateHours()
    }
    
    func getLocation() -> CLLocation? {
        return liveLocation
    }
    
    func autolocate() {
        print("\(#line) self.isLocationLive = true")
        self.isLocationLive = true
        self.geocode()
    }
    
    func updateVisibleLocation() {
        var locationString: String
        var latitude: Double
        var longitude: Double
        
        if self.isLocationLive == true {
            locationString = "\(self.placemark?.name ?? "–")\n"//", \(place!.countryCode)\n"
            latitude = self.liveLocation?.coordinate.latitude ?? 0.0
            longitude = self.liveLocation?.coordinate.longitude ?? 0.0
        } else {
            locationString = "\(self.selectedLocationName!)\n"
            latitude = self.selectedLocation?.coordinate.latitude ?? 0
            longitude = self.selectedLocation?.coordinate.longitude ?? 0
        }
        
        let latitudeString = self.numberFormatter.string(from: NSNumber(value: abs(latitude)))!
        let longitudeString = self.numberFormatter.string(from: NSNumber(value: abs(longitude)))!
        
        if latitude < 0 {
            locationString += "\(latitudeString) °S, "
        } else {
            locationString += "\(latitudeString) °N, "
        }
        if longitude < 0 {
            locationString += "\(longitudeString) °V"
        } else {
            locationString += "\(longitudeString) °A"
        }
        self.locationString = locationString
    }
    
    func updateHours() {
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
        
        self.fromDate = localMidnight
        self.toDate   = self.fromDate + 24*3600
        self.localDateString = self.dateFormatter.string(from: localMidnight)
        
        self.goldenJD = findRange(lat: self.latitude!, long: self.longitude!, start: self.fromDate, stop: self.toDate, bottom: -6.0, top: 6.0)
        self.blueJD = findRange(lat: self.latitude!, long: self.longitude!, start: self.fromDate, stop: self.toDate, bottom: -10.0, top: -6.0)
        self.sunriseSunset = findRange(lat: self.latitude!, long: self.longitude!, start: self.fromDate, stop: self.toDate, bottom: -0.0, top: 100.0)
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
        while self.golden.count < 2 {
            self.golden.append(("–", "–"))
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
        while self.blue.count < 2 {
            self.blue.append(("–", "–"))
        }
        
        self.sunrise = "–"
        self.sunset = "–"
        
        if self.sunriseSunset != nil {
            if self.sunriseSunset!.count > 0 {
                self.sunrise = self.formatter.string(from: dateFromJd(jd: sunriseSunset![0].0!) as Date)
                self.sunset = self.formatter.string(from: dateFromJd(jd: sunriseSunset![0].1!) as Date)
            }
        }
        
        print("Datastore:\(#line) \(self.fromDate) – \(self.toDate)")
        print("Datastore:\(#line) Soloppgang: \(self.sunrise), solnedgang: \(self.sunset)")
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
