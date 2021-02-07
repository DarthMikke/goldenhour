//
//  NewPlaceFormView.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 10/10/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import SwiftUI
import CoreData
import CoreLocation

struct NewPlaceFormView: View {
    @EnvironmentObject var store: Datastore
    @Environment(\.managedObjectContext) var moc
    
    @Binding var showNewPlaceForm: Bool
    
    @State var name: String = ""
    @State var latitude: String = ""
    @State var longitude: String = ""
    @State var countryCode: String = ""
    @State var gmtOffset: String = ""
    
    @State var showValidationAlert: Bool = false
    @State var validated: Bool = false
    
    @State var nameValidated: Bool = true
    @State var latitudeValidated: Bool = true
    @State var longitudeValidated: Bool = true
    @State var countryCodeValidated: Bool = true
    @State var gmtOffsetValidated: Bool = true
    
    init(showNewPlaceForm: Binding<Bool>, placemark: CLPlacemark?, location: CLLocation?) {
        self._showNewPlaceForm = showNewPlaceForm
        
        self.name = ""
        self.latitude = ""
        self.longitude = ""
        self.countryCode = ""
        self.gmtOffset = ""
        
        self._name = State(initialValue: placemark?.locality ?? "")
        
        print("NewPlaceFormView:\(#line) \(String(describing: location))")
        if let tmpLatitude = location?.coordinate.latitude {
            self._latitude = State(initialValue: "\(round(tmpLatitude*100)/100)")
        }
        
        if let tmpLongitude = location?.coordinate.longitude {
            self._longitude = State(initialValue: "\(round(tmpLongitude*100)/100)")
        }
        
        if let tmpTimeZone = placemark?.timeZone {
            self._gmtOffset = State(initialValue: "\(tmpTimeZone.secondsFromGMT())")
        }
        
        if let tmpCountryCode = placemark?.isoCountryCode {
            self._countryCode = State(initialValue: "\(tmpCountryCode)")
        }
    }
    
    func validate() -> Bool {
        return self.nameValidated && self.countryCodeValidated && self.latitudeValidated && self.longitudeValidated && self.gmtOffsetValidated
    }
    
    func validate(string: String) -> Bool {
        return string != ""
    }
    
    func validate(number no: String, min: Double? = nil, max: Double? = nil) -> Bool {
        if no == "" { return false }
        
        let legal = "-+0123456789,."
        let number = no.replacingOccurrences(of: ",", with: ".")
        var stack = number
        var separatorCount = 0
        
        while stack.count > 0 {
            let char = stack.popLast()
            if !legal.contains(char!) {
                return false
            }
            if char == "." {
                separatorCount += 1
                if separatorCount > 1 {
                    return false
                }
            }
        }
        
        if min != nil {
            if Double(number)! < min! {
                return false
            }
        }
        if max != nil {
            if Double(number)! > max! {
                return false
            }
        }
        
        return true
    }
    
    var body: some View {
        Form {
            Section(header: Text("STAD")) {
                HStack {
                    Text("Namn")
                        /// -TODO : Endre rekkefølgja på valideringa nedanfor (og på alle andre felt)
                        .foregroundColor(self.nameValidated
                                            ? (self.name == "" ? .black : .gray)
                                            : .red)
                        .frame(width: 120, alignment: .leading)
                    Spacer()
                    TextField("Namn", text: self.$name, onEditingChanged: { editing in
                        self.nameValidated = self.validate(string: self.name)
                        self.validated = self.validate()
                    })
                }
                HStack {
                    Text("Landkode")
                        .foregroundColor(self.countryCodeValidated
                                            ? (self.countryCode == "" ? .black : .gray)
                                            : .red)
                        .frame(width: 120, alignment: .leading)
                    Spacer()
                    TextField("Landkode", text: self.$countryCode, onEditingChanged: { editing in
                        self.countryCodeValidated = self.validate(string: self.countryCode)
                        self.validated = self.validate()
                    })
                }
            }
            Section(header: Text("KOORDINATAR")) {
                HStack {
                    Text("Breidde (N/S)")
                        .foregroundColor(self.latitudeValidated
                                            ? (self.latitude == "" ? .black : .gray)
                                            : .red)
                        .frame(width: 120, alignment: .leading)
                    Spacer()
                    TextField("Breiddegrad", text: self.$latitude, onEditingChanged: { editing in
                        self.latitudeValidated = self.validate(number: self.latitude, min: -90, max: 90)
                        self.validated = self.validate()
                    })
                }
                HStack {
                    Text("Lengde (A/V)")
                        .foregroundColor(self.longitudeValidated
                                            ? (self.longitude == "" ? .black : .gray)
                                            : .red)
                        .frame(width: 120, alignment: .leading)
                    Spacer()
                    TextField("Lengdegrad", text: self.$longitude, onEditingChanged: { editing in
                        self.longitudeValidated = self.validate(number: self.longitude, min: -90, max: 90)
                        self.validated = self.validate()
                    })
                }
            }
            Section(header: Text("TIDSSONE")) {
                TextField("+/-, sekund", text: self.$gmtOffset, onEditingChanged: { editing in
                    self.gmtOffsetValidated = self.validate(number: self.gmtOffset, min: -172800, max: 172800)
                    self.validated = self.validate()
                }).foregroundColor(self.gmtOffsetValidated ? .black : .red)
            }
            HStack {
                Spacer()
                Button(action: {
                    self.validated = self.validate()
                    if self.validated {
                        let place = Place(context: self.moc)
                        place.id = UUID()
                        place.name = self.name
                        place.latitude = Double(self.latitude) ?? 0.0
                        place.longitude = Double(self.longitude) ?? 0.0
                        place.countryCode = self.countryCode
                        place.gmtOffset = Int32(self.gmtOffset) ?? 0
                        print("NewPlaceFormView:\(#line) Ny plass: \(self.name), \(self.countryCode) @ (\(self.latitude),\(self.longitude)) T\(self.gmtOffset)")
                        
                        do {
                            try self.moc.save()
                        } catch let error {
                            print("NewPlaceFormView:\(#line) Lagra ikkje ny plass. Feil: \(error)")
                        }
                        
                        self.name = ""
                        self.latitude = ""
                        self.longitude = ""
                        self.countryCode = ""
                        self.gmtOffset = ""
                        self.showNewPlaceForm = false
                    }
                }) {
                    Text("Lagre")
                }.disabled(!self.validate())
                Spacer()
            }
        }
    }
}


struct NewPlaceFormView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    @State var isShowing: Bool = true

    static var previews: some View {
        NewPlaceFormView(showNewPlaceForm: .constant(true), placemark: nil, location: nil)
            .environment(\.managedObjectContext, moc)
    }
}
