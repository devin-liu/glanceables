import Foundation
import Combine

class SchedulerViewModel: ObservableObject {
    private var schedulerModel: SchedulerModel?
    private var cancellables = Set<AnyCancellable>()
    @Published private(set) var screenshotTrigger = PassthroughSubject<Void, Never>()
    @Published private(set) var reloadTrigger = PassthroughSubject<Void, Never>()

    private var screenshotAction: () -> Void = {}
    private var reloadAction: () -> Void = {}
    private var interval: TimeInterval = 60.0

    init() {}

    func configure(interval: TimeInterval, actions: @escaping (SchedulerViewModel) -> (() -> Void, () -> Void)) {
        print("configure SchedulerViewModel")
        self.interval = interval

        let (screenshotAction, reloadAction) = actions(self)
        self.screenshotAction = screenshotAction
        self.reloadAction = reloadAction

        // Configure the throttle for screenshotTrigger
        screenshotTrigger
            .throttle(for: .seconds(interval), scheduler: RunLoop.main, latest: true)
            .sink { self.screenshotAction() }
            .store(in: &cancellables)

        // Configure the throttle for reloadTrigger
        reloadTrigger
            .throttle(for: .seconds(interval), scheduler: RunLoop.main, latest: true)
            .sink { self.reloadAction() }
            .store(in: &cancellables)

        schedulerModel = SchedulerModel(interval: interval, actions: [
            { self.screenshotTrigger.send(()) },
            { self.reloadTrigger.send(()) }
        ])
    }

    func startScheduler() {
        schedulerModel?.start()
    }

    func stopScheduler() {
        schedulerModel?.stop()
    }
}
