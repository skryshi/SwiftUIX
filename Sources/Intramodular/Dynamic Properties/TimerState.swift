//
// Copyright (c) Vatsal Manot
//

import Combine
import Dispatch
import Swift
import SwiftUI

/// A property wrapper type that can maintain a timed counter.
@propertyWrapper
public struct TimerState: DynamicProperty {
    private class ValueBox: ObservableObject {
        @Published var value: Int
        
        init(_ value: Int) {
            self.value = value
        }
    }
    
    private let animation: Animation?
    private let interval: TimeInterval
    private let maxCount: Int?
    
    @State private var state = ReferenceBox<(publisher: Timer.TimerPublisher, connection: Cancellable, subscription: Cancellable)?>(nil)
    @PersistentObject private var valueBox: ValueBox
    
    public var wrappedValue: Int {
        valueBox.value
    }
    
    /// - Parameters:
    ///   - wrappedValue: The initial value for the counter.
    ///   - interval: The time interval on which to increment the counter. For example, a value of `0.5` increments the counter approximately every half-second.
    ///   - maxCount: The count at which to stop the timer.
    ///   - animation: The animation used when incrementing the counter.
    public init(
        wrappedValue: Int = 0,
        interval: TimeInterval,
        maxCount: Int? = nil,
        animation: Animation? = nil
    ) {
        self._valueBox = .init(wrappedValue: ValueBox(wrappedValue))
        self.interval = interval
        self.maxCount = maxCount
        self.animation = animation
    }
    
    public mutating func update() {
        if state.value == nil {
            let maxCount = self.maxCount
            let animation = self.animation
            let valueBox = self.valueBox
            
            let timerPublisher = Timer.publish(every: interval, on: .main, in: .common)
            let connection = timerPublisher.connect()
            var timerSubscription: Cancellable!
            
            if let maxCount = maxCount {
                timerSubscription = timerPublisher.prefix(maxCount).sink { _ in
                    withAnimation(animation) {
                        valueBox.value += 1
                    }
                }
            } else {
                timerSubscription = timerPublisher.sink { _ in
                    withAnimation(animation) {
                        valueBox.value += 1
                    }
                }
            }
            
            state.value = (timerPublisher, connection, timerSubscription)
        }
    }
}
