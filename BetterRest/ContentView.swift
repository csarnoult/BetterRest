//
//  ContentView.swift
//  BetterRest
//
//  Created by Chris Arnoult on 12/5/19.
//  Copyright © 2019 Chris Arnoult. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 0
    let cupsOfCoffee: [Int] = Array(1...20)
    
    var body: some View {
        NavigationView {
            Form {
                Text("When do you want to wake up?")
                    .font(.headline)
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                
                Section(header: Text("Desired amount of sleep")) {
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g")")
                    }
                }
                
                Section(header: Text("Daily coffee intake")) {
                    Picker("Number of cups", selection: $coffeeAmount) {
                        ForEach(0 ..< cupsOfCoffee.count) {
                            Text("\(self.cupsOfCoffee[$0])")
                        }
                    }
                }
                
                Section(header: Text("You should go to bed at...")) {
                    Text("\(calculateBedTime())")
                }
            }
                .navigationBarTitle("BetterRest")
        }
    }
    func calculateBedTime() -> String {
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        var result = ""
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            result = formatter.string(from: sleepTime)
        } catch {
            result = "Sorry, there was a problem calculating your bedtime."
        }
        return result
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
