//
//  TimeTable.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 19/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import SwiftUI

struct TimeTable: View {
    @EnvironmentObject var store: Datastore
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "sunrise")
                        Spacer()
                        Text(self.store.sunrise)
                    }
                    .padding(5.0)
                    .padding(.top, 10.0)
                    HStack {
                        Text("Blå time")
                        Spacer()
                        TimeRange(self.store.blue[0].0, self.store.blue[0].1)
                    }
                    .padding(5.0)
                    .background(Color("BlueHour"))
                    HStack {
                        Text("Gylden time")
                        Spacer()
                        TimeRange(self.store.golden[0].0, self.store.golden[0].1)
                    }
                    .padding(5.0)
                    .background(Color("GoldenHour"))
                    HStack {
                        Text("Gylden time")
                        Spacer()
                        TimeRange(self.store.golden[1].0, self.store.golden[1].1)
                    }
                    .padding(5.0)
                    .background(Color("GoldenHour"))
                    HStack {
                        Text("Blå time")
                        Spacer()
                        TimeRange(self.store.blue[1].0, self.store.blue[1].1)
                    }
                    .padding(5.0)
                    .background(Color("BlueHour"))
                    HStack {
                        Image(systemName: "sunset")
                        Spacer()
                        Text(self.store.sunset)
                    }
                    .padding(5.0)
                }
//                .frame(width: 260.0)
                HStack {
                    Image(systemName: "chevron.left")
                    Text(self.store.localDate)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.right")
                }
                .font(.title)
                .padding(.bottom, 15.0)
                .padding(.top, 20.0)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .foregroundColor(Color("ForegroundColor"))
            .cornerRadius(10)
            Spacer()
        }
        .padding(20)
    }
}
