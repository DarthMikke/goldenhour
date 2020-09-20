//
//  TimeTableRow.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 20/09/2020.
//  Copyright © 2020 Michal Jan Warecki. All rights reserved.
//

import SwiftUI

struct TimeTableRow: View {
    var leftString: String?
    var leftImage: Image?
    var right: String
    var isString: Bool
    
    init(_ left: String, _ right: String) {
        self.leftString = left
        self.leftImage = nil
        self.isString = true
        self.right = right
    }
    init(_ left: Image, _ right: String) {
        self.leftString = nil
        self.leftImage = left
        self.isString = false
        self.right = right
    }
    
    var body: some View {
        HStack {
            
        }
    }
}

//struct TimeTableRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeTableRow()
//    }
//}
