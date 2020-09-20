//
//  TimeRange.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 19/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import Foundation
import SwiftUI

let hourWidth: CGFloat = 50.0

struct TimeRange: View {
    var from: String
    var to: String
    
    init(_ from: String, _ to: String) {
        self.from = from
        self.to = to
    }
    
    var body: some View {
        HStack {
            Text(self.from)
                .multilineTextAlignment(.trailing)
                .frame(width: hourWidth)
            Text("–")
            Text(self.to)
                .multilineTextAlignment(.trailing)
                .frame(width: hourWidth)
        }
    }
}


//struct TimeRange_Previews: PreviewProvider {
//    static var previews: some View {
//        HStack {
//            VStack {
//                Text("Blå time")
//                Text("Gylden time")
//            }
//            VStack {
//                TimeRange(2459112.5, 2459113.5)
//                TimeRange(2459112.876, 2459113.112)
//            }
//        }
//        .frame(width: 260.0)
//    }
//}
