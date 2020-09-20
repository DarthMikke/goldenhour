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
    var place: Place
    
    var body: some View {
        VStack {
            HStack {
                Text("\(self.place.name), \(self.place.countryCode)")
                Spacer()
            }
            HStack {
                Text("\(self.place.lat) N, \(self.place.long) A")
                Spacer()
            }
        }
    }
}

struct PlacePickerView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceRow(place: placesData[0])
    }
}
