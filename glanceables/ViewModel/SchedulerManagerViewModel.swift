import Foundation
import Combine

class SchedulerViewModel: ObservableObject {
    private var schedulerModel: SchedulerModel?
    private var cancellables = Set<AnyCancellable>()
    private let screenshotTrigger = PassthroughSubject<Void, Never>()
    private let reloadTrigger = PassthroughSubject<Void, Never>()
    
    init(interval: TimeInterval = 60.0, actions: [() -> Void]) {
        schedulerModel = SchedulerModel(interval: interval, actions: actions)
        
        // Configure the throttle for screenshotTrigger
        screenshotTrigger
            .throttle(for: .seconds(60), scheduler: RunLoop.main, latest: true)
            .sink { actions[0]() }
            .store(in: &cancellables)
        
        // Configure the throttle for reloadTrigger
        reloadTrigger
            .throttle(for: .seconds(60), scheduler: RunLoop.main, latest: true)
            .sink { actions[1]() }
            .store(in: &cancellables)
    }
    
    func startScheduler() {
        schedulerModel?.start()
    }
    
    func stopScheduler() {
        schedulerModel?.stop()
    }
    
    func triggerScreenshot() {
        screenshotTrigger.send(())
    }
    
    func triggerReload() {
        reloadTrigger.send(())
    }
}
