//: [Previous](@previous)

import PlaygroundSupport
import SwiftUI
import EventKit

class noView {
    private var message = "Ventar…"
    private var eventStore = EKEventStore()
    
    func saveToCalendar() {
        // Check for privileges
        print("Ventar på kalenderen")
        
        eventStore.requestAccess(to: .event) { granted, error in
            if (error != nil) {
                self.message = "Error: \(error)"
                print(self.message)
                return
            }
            self.message = "Fekk tilgang"
            print(self.message)
        }
        // Take JD date and time
        
        
    }
}

struct ContentView: View {
    @State private var hasTimeElapsed = false
    @State private var message = "Ventar…"
    private var eventStore = EKEventStore()
    
    func saveToCalendar() {
        // Check for privileges
        print("Ventar på kalenderen")
        
        eventStore.requestAccess(to: .event) { granted, error in
            print("completion")
            if (error != nil) {
                self.message = "Error: \(error)"
                print(self.message)
                return
            }
            self.message = "Fekk tilgang"
            print("OK")
        }
        // Take JD date and time
        
        
    }
    
    var body: some View {
        NavigationView {
            Text(message)
        }
        .background(Color.white)
        .onAppear(perform: self.saveToCalendar)
//        Text(hasTimeElapsed ? "Sorry, too late." : "Please enter above.")
//            .onAppear(perform: delayText)  // Triggered when the view first appears. You could
                                           // also hook the delay up to a Button, for example.
    }
    
    private func delayText() {
        // Delay of 7.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
            hasTimeElapsed = true
        }
    }
}

//PlaygroundPage.current.setLiveView(ContentView())



//: [Next](@next)

let eventStore = EKEventStore()
var authorized: Bool = false
switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
case .authorized:
    print("Authorized")
    authorized = true
case .denied:
    print("Denied")
case .notDetermined:
    print("Not determined")
default:
    print("Default")
}
var userAllowed = false
if !authorized {
    eventStore.requestAccess(to: .event, completion: { (allowed, error) -> Void in
        userAllowed = !allowed
        print(userAllowed ? "Allowed" : "Not allowed")
    })
}
