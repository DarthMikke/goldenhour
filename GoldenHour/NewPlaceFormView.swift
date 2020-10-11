//
//  NewPlaceFormView.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 10/10/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import SwiftUI

struct NewPlaceFormView: View {
    @EnvironmentObject var store: Datastore
    @Environment(\.managedObjectContext) var moc
    
    @Binding var showNewPlaceForm: Bool
    @State var name: String = ""
    @State var latitude: String = ""
    @State var longitude: String = ""
    @State var countryCode: String = ""
    @State var gmtOffset: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("STAD")) {
                TextField("Namn", text: self.$name)
                TextField("Landkode", text: self.$countryCode)
            }
            Section(header: Text("KOORDINATAR")) {
                TextField("Breiddegrad", text: self.$latitude)
                TextField("Lengdegrad", text: self.$longitude)
            }
            Section(header: Text("TIDSONE")) {
                TextField("GMT offset", text: self.$gmtOffset)
            }
            Button("Lagre") {
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
        }
    }
}

//struct NewPlaceFormView_Previews: PreviewProvider {
////    @State var isShowing: Bool = true
//
//    static var previews: some View {
//        NewPlaceFormView(showNewPlaceForm: .constant(true))
//    }
//}
