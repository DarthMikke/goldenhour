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
import EventKit

struct SunTimes {
    //TODO: Set ut til eiga fil
    var golden:     Array<(String, String)>
    var blue:       Array<(String, String)>
    var sunrise:    String
    var sunset:     String
    var goldenJD:   Array<(Double?, Double?)>
}

enum Locations {
    case live
    case nonlive
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
    @Published  var selectedLocation: CLLocation? {
        willSet { objectWillChange.send() }
    }
    private     var selectedLocationName: String?
    
    private     var latitude:           Double?
    private     var longitude:          Double?
    @Published  var locationString:     String {
        willSet { objectWillChange.send() }
    }
    @Published  var liveLocationString: String {
        willSet { objectWillChange.send() }
    }
    @Published  var liveLocationShortString: String {
        willSet { objectWillChange.send() }
    }
    
    private     var fromDate:   Date
    private     var toDate:     Date
    @Published  var sunTimes:   SunTimes {
        willSet { objectWillChange.send() }
    }
    @Published  var localDateString:  String
    @Published  var localDate:  Date {
        didSet(newValue) {
            print("Datastore:\(#line) Ny dato: \(newValue)")
            self.updateHours()
        }
    }

    @Published  var savingState:    EventState = .loading
    @State private var message = "Ventar for tilgang til kalender…"
    private     var eventStore = EKEventStore()
    @State private var calendarAccess = true
    
    override init() {
        self.isLocationLive = true
        self.liveLocationShortString = "Søkjer etter posisjon…"
        self.liveLocationString = "Søkjer etter posisjon…\n"
        self.locationString = "Søkjer etter posisjon…\n"
        
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
        self.numberFormatter.maximumFractionDigits = 2
        
        self.localDate = Date()
        self.fromDate = lastMidnight()!
        self.toDate = Date(timeInterval: 24*3600, since: self.fromDate)
        self.formatter = DateFormatter()
        self.dateFormatter = DateFormatter()
        self.sunTimes = SunTimes(golden: [("–", "–"), ("–", "–")],
                                 blue: [("–", "–"), ("–", "–")],
                                 sunrise: "–", sunset: "–",
                                 goldenJD: [])
        self.localDateString = ".."
        
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.formatter.timeZone = .current
        self.formatter.dateFormat = "HH:mm"
        self.dateFormatter.dateFormat = "dd.MM.yyyy"
        
        // print(self.places)
    }
    
    /// Oppdaterer `self.placemark` i tråd med `self.liveLocation` eller `self.selectedLocation`
    private func geocode() {
        guard let location = self.isLocationLive ? self.liveLocation : self.selectedLocation
            else { return }
        self.geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
            print("Datastore:\(#line) \(String(describing: places))")
            if error == nil {
                self.placemark = places?[0]
                
                print("Datastore:\(#line) New location: \((self.isLocationLive ? self.liveLocation : self.selectedLocation) == nil ? "–" : String(describing: location.coordinate))") // TODO: Det ser ut til at denne linja eigenleg er unødvendig
                print("Datastore:\(#line) New placemark: \(self.placemark?.name ?? "–") with timezone: \(String(describing: self.placemark?.timeZone?.secondsFromGMT()))")
                
            } else {
                self.placemark = nil
            }
        })
    }
    
    func setLocation(to place: Place, isLiveLocation: Bool = false) {
        /// Manuell lokasjonssetjing. Oppdaterer plass fyrst, så tidspunkt.
        print("Datastore:\(#line) Set lokasjon til \(String(describing: place.name))")
        self.isLocationLive = false
        
        ///#Oppdater plass
        self.selectedLocationName = place.name
        let temporaryLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        self.selectedLocation = temporaryLocation
        self.geocode()
        self.updateVisibleLocation()
        // self.placemark = CLPlacemark(location: temporaryLocation, name: place.name, postalAddress: nil)
        
        ///#Oppdater tidspunkt
        self.formatter.timeZone = TimeZone(secondsFromGMT: Int(place.gmtOffset))
        self.dateFormatter.timeZone = self.formatter.timeZone
        self.updateHours()
    }
    
    /// Set lokasjonen til live med `setLocation(to: .live)`
    func setLocation(to location: Locations) {
        if location == .live {
            self.isLocationLive = true
            self.locationString = self.liveLocationString
//            self.geocode()
            self.formatter.timeZone = self.placemark?.timeZone
        }
        // else throw
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
        
        /// @TODO: Oppdater til å bruke SunHours
        
        let goldenJD: Array<(Double?, Double?)> = findRange(lat: self.latitude!, long: self.longitude!,
                                                            start: self.fromDate, stop: self.toDate,
                                                            bottom: -6.0, top: 6.0)
        let blueJD: Array<(Double?, Double?)> = findRange(lat: self.latitude!, long: self.longitude!,
                                                          start: self.fromDate, stop: self.toDate,
                                                          bottom: -10.0, top: -6.0)
        let sunriseSunset: Array<(Double?, Double?)>? = findRange(lat: self.latitude!, long: self.longitude!,
                                                                 start: self.fromDate, stop: self.toDate,
                                                                 bottom: -0.0, top: 100.0)
        var golden: Array<(String, String)> = []
        var blue: Array<(String, String)> = []
        var (sunrise, sunset) = ("–", "–")
        
        for sequence in goldenJD {
            var start = "–"
            var stop = "–"
            if sequence.0 != nil {
                start = self.formatter.string(from: dateFromJd(jd: sequence.0!) as Date)
            }
            if sequence.1 != nil {
                stop = self.formatter.string(from: dateFromJd(jd: sequence.1!) as Date)
            }
            golden.append((start, stop))
        }
        while golden.count < 2 {
            golden.append(("–", "–"))
        }
        
        for sequence in blueJD {
            var start = "–"
            var stop = "–"
            if sequence.0 != nil {
                start = self.formatter.string(from: dateFromJd(jd: sequence.0!) as Date)
            }
            if sequence.1 != nil {
                stop = self.formatter.string(from: dateFromJd(jd: sequence.1!) as Date)
            }
            blue.append((start, stop))
        }
        while blue.count < 2 {
            blue.append(("–", "–"))
        }
        
        sunrise = "–"
        sunset = "–"
        
        if sunriseSunset != nil {
            if sunriseSunset!.count > 0 {
                sunrise = self.formatter.string(from: dateFromJd(jd: sunriseSunset![0].0!) as Date)
                sunset  = self.formatter.string(from: dateFromJd(jd: sunriseSunset![0].1!) as Date)
            }
        }
        
        let sunTimes = SunTimes(golden: golden, blue: blue,
                                sunrise: sunrise, sunset: sunset,
                                goldenJD: goldenJD)
        self.sunTimes = sunTimes
        
        print("Datastore:\(#line) \(self.fromDate) – \(self.toDate)")
        print("Datastore:\(#line) Soloppgang: \(sunrise), solnedgang: \(sunset)")
    }

    func updateDate(timeInterval: Int) {
        let newDate = Date(timeInterval: Double(timeInterval), since: self.localDate)
        self.localDate = newDate
    }
    
    private func updateLiveLocationString() {
        var locationString: String
        let latitude: Double
        let longitude: Double
        let latitudeString: String
        let longitudeString: String
        
        locationString = "\(self.placemark?.locality ?? "Ukjent stad")"
        self.liveLocationShortString = locationString
        print("Datastore:\(#line) Set location to \(self.liveLocationShortString)")
        
        latitude = self.liveLocation?.coordinate.latitude ?? 0.0
        longitude = self.liveLocation?.coordinate.longitude ?? 0.0
        latitudeString = self.numberFormatter.string(from: NSNumber(value: abs(latitude)))!
        longitudeString = self.numberFormatter.string(from: NSNumber(value: abs(longitude)))!
        
        locationString += "\n"
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
        self.liveLocationString = locationString
        if self.isLocationLive {
            self.locationString = locationString
        }
    }
    
    private func liveLocationHandler(location: CLLocation) {
        print("Datastore:\(#line) \(String(describing: location))")
        self.liveLocation = location
        self.geocode()
        self.updateHours()
        if self.isLocationLive { self.setLocation(to: .live) }
        
        if self.placemark == nil { return }
        self.updateLiveLocationString()
        self.locationManager.stopUpdatingLocation()
    }
    
    func requestAccess() -> Bool {
        var authorized: Bool = false
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
        case .authorized:
            print("Authorized")
            authorized = true
        case .denied:
            print("Denied")
        case .notDetermined:
            print("Not determined")
        default:
            print("Default")
        }
        
        if !authorized {
            self.eventStore.requestAccess(to: .event, completion: { (allowed, error) -> Void in
                if (error != nil) {
                    self.message = "Error: \(String(describing: error))"
                    print(self.message)
                    return
                }
                self.message = allowed ? "Fekk tilgang" : "Ingen tilgang"
                print(self.message)
            })
        }
        return authorized
    }
    
    func saveToCalendar() {
        self.savingState = .loading
        // Check for privileges
        print("Ventar på kalenderen")
        let access = self.requestAccess()
        // Take JD date and time
        
        if !access {
            // Only if access is set first time
            self.calendarAccess = false
        }
        if !self.calendarAccess {
            // Return if no access to calendar
            return
        }
        
        var saved: Bool = true
        
        for jdPair in self.sunTimes.goldenJD {
            do {
                try saved = self.saveEvent(
                    startDate: dateFromJd(jd: jdPair.0!) as Date,
                    endDate: dateFromJd(jd: jdPair.1!) as Date
                )
                print(self.message)
            } catch {
                message = "\(#file):\(#line) Feil under lagring: \(error)"
                saved = false
                print(message)
            }
            if !saved { break }
        }
        
        // Only update saved status after trying to save the last event
        self.savingState = saved ? .success : .failed
    }
    
    func saveEvent(startDate: Date, endDate: Date) throws -> Bool {
        var result: Bool = true
        
        let event = EKEvent(eventStore: self.eventStore)
        event.title = "GoldenHour"
        event.calendar = self.eventStore.defaultCalendarForNewEvents
        event.startDate = startDate
        event.endDate = endDate
        
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
        } catch {
            result = false
            throw error
        }
        
        return result
    }
}

extension Datastore: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.liveLocationHandler(location: location)
//        self.geocode()
    }
}
