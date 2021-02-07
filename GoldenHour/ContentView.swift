//
//  ContentView.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 18/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var store:          Datastore
                    var dateFormatter:  DateFormatter
    @State          var showPicker:     Bool = false
    @State          var showNewPlaceForm: Bool = false
    @Environment(\.managedObjectContext) var moc
    
    init() {
        self.store = Datastore()
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "dd.MM.yyyy"
//        self.showPicker = false
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView {
                    TimeTable()
                        .environmentObject(self.store)
                        .alignmentGuide(VerticalAlignment.center, computeValue: {_ in 0})
                }
                HStack {
                    Spacer()
                    VStack {
                        Text("\(self.store.locationString)")
                    }.padding(10)
                    .padding(.bottom, 10)
                    Spacer()
                    //            PlacePicker().tabItem {
                    //                Image(systemName: "mappin")
                    //                Text("Stader")
                    //            }
                }.onTapGesture(count: 1, perform: {
                    print("Vis PlacePicker")
                    self.showPicker = true
                })
                .sheet(isPresented: self.$showPicker, content: {
//                    PlacePicker(placesData: load("placesData.json"))
                    NavigationView {
                        PlacePicker(showSelf: self.$showPicker)
                            .environment(\.managedObjectContext, moc)
                            .environmentObject(self.store)
                            .navigationBarItems(trailing: HStack {
                                Button(action: { self.showNewPlaceForm = true },
                                       label: { newPlaceButtonLabel })
                                    .font(.headline)
                                Button(action: { self.showPicker = false },
                                       label: { Image(systemName: "xmark") })
                                    .font(.headline)
                            })
                            .navigationBarTitle(Text("Stader"))
                            .sheet(isPresented: self.$showNewPlaceForm, content: {
                                NavigationView {
                                    NewPlaceFormView(showNewPlaceForm: self.$showNewPlaceForm,
                                                     placemark: self.store.placemark,
                                                     location: self.store.getLocation())
                                        .environment(\.managedObjectContext, moc)
                                        .environmentObject(self.store)
                                        .navigationBarTitle(Text("Ny stad"))
                                        .navigationBarItems(trailing: Button(action: {
                                            self.showNewPlaceForm = false
                                        }) {
                                            Image(systemName: "xmark")
                                        })
                                }
                            })
                    }
                })
                .background(Color("CardBackground"))
                .cornerRadius(10)
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
    
    let newPlaceButtonLabel: some View = HStack {
                     Image(systemName: "plus")
                     Text("Legg til plass")
                 }.padding()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
