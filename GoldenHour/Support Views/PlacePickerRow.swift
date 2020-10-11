//
//  PlacePickerView.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 19/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import SwiftUI
import CoreLocation

struct PlaceRow: View {
    var name:   String?
    var latitude: Double
    var longitude: Double
    var countryCode: String?
    
    init(place: Place) {
        self.name = place.name
        self.latitude = place.latitude
        self.longitude = place.longitude
        self.countryCode = place.countryCode
        
    }
    
    init(name: String, latitude: Double, longitude: Double, countryCode: String) {
        /// For preview
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.countryCode = countryCode
    }
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("\(self.name ?? "Ukjent"), \(self.countryCode ?? "Ukjent land")")
                    Spacer()
                }
                HStack {
                    Text("\(self.latitude ) N, \(self.longitude ) A")
                    Spacer()
                }
            }
//            Spacer()
//            Button(action: {
//                // Fjern elementet
//                return
//            }) {
//                Image("xmark")
//            }
        }
    }
}

/// #Only for preview:
struct PlacePickerView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceRow(name: "Tromsø", latitude: 69.651944, longitude: 18.953333, countryCode: "NO")
//        Text("PlaceRow")
    }
}
