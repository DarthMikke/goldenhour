//
//  TimeCard.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 19/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import SwiftUI

struct TimeTable: View {
    @EnvironmentObject  var store:  Datastore
    @State              var showDatePicker: Bool = false
//    @State              var date:   Date {
//        didSet(newValue) {
//            print("New date: \(newValue)")
//            self.store.localTime = self.date
//        }
//    }
    
//    init() {
//        let placeholderDate = Date()
//        self.date = placeholderDate
//    }
    
    func toggleDatePicker() {
        self.showDatePicker = !self.showDatePicker
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
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
                    Spacer().frame(width: 10)
                    Button(action: {self.store.localDate = Date(timeInterval:  -24*3600, since: self.store.localDate)}) {
                        Image(systemName: "chevron.left")
                    }
                    Text(self.store.localDateString)
                        .fontWeight(.bold)
                        .onTapGesture {
                            withAnimation {
                                self.toggleDatePicker()
                            }
                        }
                    Button(action: {self.store.localDate = Date(timeInterval:  24*3600, since: self.store.localDate)}) {
                        Image(systemName: "chevron.right")
                    }
                    Spacer().frame(width: 10)
                }
                .font(.title)
                .padding(.bottom, 15.0)
                .padding(.top, 20.0)
                
                
                if self.showDatePicker {
//                    Form {
                    HStack {
                        Spacer()
                        DatePicker("", selection: self.$store.localDate, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .transition(.slide)
//                    }
                        Spacer(minLength: 30)
                    }
                }
            }
            .background(Color("CardBackground").edgesIgnoringSafeArea(.all))
            .foregroundColor(Color("ForegroundColor"))
            .cornerRadius(10)
        }
        .padding(20)
    }
}
