import Foundation


struct SlidingWindow: RLAlgo {
    /// In order to keep track of the window we will need to have a window size, and tokens that can be spend during this window
    private let window: Duration
    private let maxCount: Int

    private var dataSource: [Duration] = []
    private var counter: Int {
        dataSource.count
    }
    private var clock: ContinuousClock.Instant

    init(window: Duration, count: Int, counter: Int = 0) {
        self.window   = window
        self.maxCount = count
        self.clock    = .now
    }
    
    mutating func consume() throws(RLError) {
        guard windowAvailability() else { throw RLError.limitExceeded }
        
        self.saveProgress()
    }

    /// Window Availability Logic
    mutating private func saveProgress() {
        self.dataSource.append(
            clock.duration(to: .now)
        )
    }
    
    /// Window Availability Logic
    /// - If number of actions has not exceeded the limit - proceed
    ///     - Save timestamp of each action
    /// - Else, check current window length vs. given window length
    /// - Get the extra window duration to get cutoff timestamp
    /// - Remove the action with timestamps lower than cutoff
    /// - NOW, If number of actions has not exceeded the limit - proceed else - dont
    mutating private func windowAvailability() -> Bool {
        if counter < maxCount { return true }
        else {
            let runningWindow = clock.duration(to: .now)
            if runningWindow > window {
                var newDataSource = dataSource
                newDataSource.removeAll { duration in
                    duration < (runningWindow - window)
                }
                self.dataSource = newDataSource
            }
            
            return counter < maxCount
        }
    }
}
