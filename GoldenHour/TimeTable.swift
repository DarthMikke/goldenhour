//
//  TimeTable.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 09/02/2021.
//  Copyright © 2021 Michal Jan Warecki. All rights reserved.
//

import SwiftUI

struct TimeTable: View {
    var model: SunTimes

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "sunrise")
                Spacer()
                Text(self.model.sunrise)
            }
            .padding(5.0)
            .padding(.top, 10.0)
            HStack {
                Text("Blå time")
                Spacer()
                TimeRange(self.model.blue[0].0, self.model.blue[0].1)
            }
            .padding(5.0)
            .background(Color("BlueHour"))
            HStack {
                Text("Gylden time")
                Spacer()
                TimeRange(self.model.golden[0].0, self.model.golden[0].1)
            }
            .padding(5.0)
            .background(Color("GoldenHour"))
            HStack {
                Text("Gylden time")
                Spacer()
                TimeRange(self.model.golden[1].0, self.model.golden[1].1)
            }
            .padding(5.0)
            .background(Color("GoldenHour"))
            HStack {
                Text("Blå time")
                Spacer()
                TimeRange(self.model.blue[1].0, self.model.blue[1].1)
            }
            .padding(5.0)
            .background(Color("BlueHour"))
            HStack {
                Image(systemName: "sunset")
                Spacer()
                Text(self.model.sunset)
            }
            .padding(5.0)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTable(model: SunTimes(golden: [("07:27", "09:42"), ("15:01", "17:16")],
                                  blue: [("06:49", "07:27"), ("17:16", "17:54")],
                                  sunrise: "08:28", sunset: "16:15",
                                  goldenJD: []))
    }
}
