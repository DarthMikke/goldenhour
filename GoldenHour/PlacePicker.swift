//
//  PlacePicker.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 19/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import SwiftUI
import CoreLocation

struct PlacePicker: View {
    var body: some View {
        List(placesData) { place in
            PlaceRow(place: place).onTapGesture(count: 1, perform: {
                print(place.id)
            })
        }
    }
}

struct PlacePicker_Previews: PreviewProvider {
    static var previews: some View {
        PlacePicker()
    }
}
