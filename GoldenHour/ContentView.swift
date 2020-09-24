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
                ScrollView {
//                    Spacer()
                    TimeTable().environmentObject(self.store).alignmentGuide(VerticalAlignment.center, computeValue: {_ in 0})
                    //                .font(.system(size: 15, weight: .heavy))
                    //.tabItem {
                    //                Image(systemName: "sun.min.fill")
                    //                Text("Tidspunkt")
                    //            }
//                    Spacer()
                }
                HStack {
                    Spacer()
                    VStack {
                        Text("\(self.store.placemark?.name ?? "Ukjent stad")")
                        Text("\((self.store.placemark?.timeZone ?? TimeZone.current)!)")
                    }.padding(10)
                    .padding(.bottom, 10)
                    Spacer()
                    //            PlacePicker().tabItem {
                    //                Image(systemName: "mappin")
                    //                Text("Stader")
                    //            }
                }
                .background(Color.white)
                .cornerRadius(10)
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
