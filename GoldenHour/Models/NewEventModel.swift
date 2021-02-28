//
//  NewEventModel.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 25/02/2021.
//  Copyright © 2021 Michal Jan Warecki. All rights reserved.
//

import Foundation

struct EventModel {
    var eventName: String = "Golden Hour"
    var place: Place
    var location: String
    var startDate: Date
    var endDate: Date
}
