import Foundation
import Combine

class SchedulerModel {
    private var timer: Timer?
    private let interval: TimeInterval
    private let actions: [() -> Void]
    
    init(interval: TimeInterval = 60.0, actions: [() -> Void]) {
        self.interval = interval
        self.actions = actions
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.actions.forEach { $0() }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
