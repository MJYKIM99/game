import Foundation
import SpriteKit

// MARK: - PowerUp Types
enum PowerUpType: CaseIterable {
    case healthBoost
    case rapidFire
    case shield

    var displayName: String {
        switch self {
        case .healthBoost:
            return "Health Boost"
        case .rapidFire:
            return "Rapid Fire"
        case .shield:
            return "Shield"
        }
    }

    var color: SKColor {
        switch self {
        case .healthBoost:
            return .green
        case .rapidFire:
            return .orange
        case .shield:
            return .blue
        }
    }

    var iconEmoji: String {
        switch self {
        case .healthBoost:
            return "❤️"
        case .rapidFire:
            return "🔥"
        case .shield:
            return "🛡️"
        }
    }

    var duration: TimeInterval? {
        switch self {
        case .healthBoost:
            return nil  // Instant effect
        case .rapidFire:
            return 10.0  // 10 seconds
        case .shield:
            return 15.0  // 15 seconds
        }
    }

    var spawnWeight: Int {
        switch self {
        case .healthBoost:
            return 3  // More common
        case .rapidFire:
            return 2
        case .shield:
            return 1  // Less common
        }
    }
}

// MARK: - PowerUp Data Structure
struct PowerUpData {
    let type: PowerUpType
    let value: Float
    let duration: TimeInterval?

    init(type: PowerUpType) {
        self.type = type
        self.duration = type.duration

        switch type {
        case .healthBoost:
            value = 30.0  // Restore 30 health
        case .rapidFire:
            value = 0.5   // 50% faster shooting
        case .shield:
            value = 1.0   // 100% damage reduction
        }
    }
}

// MARK: - Active PowerUp Tracker
@MainActor
class ActivePowerUp {
    let type: PowerUpType
    let data: PowerUpData
    private let startTime: TimeInterval
    private var timer: Timer?
    private var onDeactivate: (() -> Void)?

    var timeRemaining: TimeInterval
    var isActive: Bool = true

    init(type: PowerUpType, onDeactivate: @escaping () -> Void) {
        self.type = type
        self.data = PowerUpData(type: type)
        self.startTime = Date().timeIntervalSince1970
        self.timeRemaining = data.duration ?? 0
        self.onDeactivate = onDeactivate

        if let duration = data.duration {
            startTimer(duration: duration)
        }
    }

    private func startTimer(duration: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                let elapsed = Date().timeIntervalSince1970 - self.startTime
                self.timeRemaining = max(0, duration - elapsed)

                if self.timeRemaining <= 0 {
                    self.deactivate()
                }
            }
        }
    }

    func getTimer() -> Timer? {
        return timer
    }

    func deactivate() {
        timer?.invalidate()
        timer = nil
        isActive = false
        onDeactivate?()
    }

    var progress: Float {
        guard let duration = data.duration, duration > 0 else { return 1.0 }
        return Float(timeRemaining / duration)
    }
}