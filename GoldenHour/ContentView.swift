//
//  ContentView.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 18/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var store: Datastore
    var dateFormatter: DateFormatter
    
    init() {
        self.store = Datastore()
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "dd.MM.yyyy"
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)
            VStack {
                TimeTable().environmentObject(self.store)
//                .font(.system(size: 15, weight: .heavy))
            //.tabItem {
//                Image(systemName: "sun.min.fill")
//                Text("Tidspunkt")
//            }
            
//            PlacePicker().tabItem {
//                Image(systemName: "mappin")
//                Text("Stader")
//            }
                HStack {
                    Spacer()
                    VStack {
                        Text("\(self.store.placemark?.name ?? "Ukjent stad")")
                        Text("\((self.store.placemark?.timeZone ?? TimeZone(secondsFromGMT: 900))!)")
                    }.padding(10)
                    Spacer()
                }
                .background(Color.white)
                .cornerRadius(10)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
