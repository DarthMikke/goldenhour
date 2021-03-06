//
//  PlacePicker.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 19/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import SwiftUI
//import CoreLocation

struct PlacePicker: View {
    @FetchRequest(entity: Place.entity(), sortDescriptors: []) var places: FetchedResults<Place>
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var environment: Datastore
    @Binding var showSelf: Bool
    
    var isPreview: Bool = false
    
    var body: some View {
        VStack {
            List {
                VStack {
                    HStack {
                        //                            Text(self.store.locationString)
                        Text("\(self.environment.placemark?.name ?? "Ukjent stad")")
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Noverande posisjon")
                        Spacer()
                    }
                    //                        HStack {
                    //                            Text("\(self.latitude ) N, \(self.longitude ) A")
                    //                            Spacer()
                    //                        }
                }.onTapGesture {
                    self.environment.setLocation(to: .live)
                    self.showSelf = false
                }
                if !isPreview {
                    ForEach(self.places) { place in
                        PlaceRow(place: place)
                            .onTapGesture(count: 1, perform: {
                                if place.id != nil {
//                                self.store.setLocation(id: place.id!)
                                    self.environment.setLocation(to: place)
                                    self.showSelf = false
                                }
                                print(place.id ?? "–")
                            })
                    }.onDelete(perform: deletePlace)
                }
                if isPreview {
                    ForEach(1..<3, id: \.self) {
                        PlaceRow(name: "Tromsø \($0)", latitude: 69.651944, longitude: 18.953333, countryCode: "NO")
                    }
                }
            }
        }
    }
    
    func deletePlace(at offsets: IndexSet) {
        for offset in offsets {
            // find this book in our fetch request
            let place = places[offset]

            // delete it from the context
            moc.delete(place)
        }

        // save the context
        try? moc.save()
    }
}

struct PlacePickerPreview: View {
    @State var showSelf = true
    
    var body: some View {
        PlacePicker(showSelf: $showSelf, isPreview: true)
            .environmentObject(Datastore())
    }
}

struct PlacePicker_Previews: PreviewProvider {
    static var previews: some View {
    PlacePickerPreview()
    }
}
