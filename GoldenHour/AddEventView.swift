//
//  AddEventView.swift
//  GoldenHour
//
//  Created by Michal Jan Warecki on 25/02/2021.
//  Copyright © 2021 Michal Jan Warecki. All rights reserved.
//

import SwiftUI
import EventKit

struct AddEventView: View {
    @Binding var showNewEventModal: Bool
    @Binding var state: EventState
    
    var body: some View {
        if self.state == .loading {
            Loading()
        } else {
            Text("Fullført")
        }
    }
}

struct Loading: View {
    var body: some View {
        Spinner(isAnimating: true, style: .large, color: .gray)
    }
}

/// @NigelGee
/// https://www.hackingwithswift.com/forums/ios/showing-a-loading-view-within-a-collection-view-section/2151
struct Spinner: UIViewRepresentable {
    let isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    let color: UIColor

    func makeUIView(context: UIViewRepresentableContext<Spinner>) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: style)
        spinner.hidesWhenStopped = true
        spinner.color = color
        return spinner
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Spinner>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        Loading()
    }
}
