//
//  TimeCard.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 19/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//
import SwiftUI



struct TimeCard: View {
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
                TimeTable(model: self.store.sunTimes)
//                .frame(width: 260.0)
                HStack {
                    Spacer().frame(width: 10)
                    Button(action: { self.store.updateDate(timeInterval: -24*3600) } ) {
                        Image(systemName: "chevron.left")
                    }
                    Text(self.store.localDateString)
                        .fontWeight(.bold)
                        .onTapGesture {
                            withAnimation {
                                self.toggleDatePicker()
                            }
                        }
                    Button(action: { self.store.updateDate(timeInterval:  24*3600) } ) {
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
                
                Button(action: {}, label: {
                    Text("Legg til i kalenderen")
                    Image(systemName: "calendar.badge.plus")
                })
                .padding(.bottom, 5.0)
            }
            .background(Color("CardBackground").edgesIgnoringSafeArea(.all))
            .foregroundColor(Color("ForegroundColor"))
            .cornerRadius(10)
        }
        .padding(20)
    }
}

struct TimeTable_Previews: PreviewProvider {
    static var previews: some View {
        TimeCard()
            .environmentObject(Datastore())
            .background(Color.gray)
    }
}
