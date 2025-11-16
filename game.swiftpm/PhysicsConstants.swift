import Foundation
import SpriteKit

struct PhysicsCategory {
    static let none: UInt32 = 0x0
    static let player: UInt32 = 0x1 << 0
    static let enemy: UInt32 = 0x1 << 1
    static let playerProjectile: UInt32 = 0x1 << 2
    static let enemyProjectile: UInt32 = 0x1 << 3
    static let boundary: UInt32 = 0x1 << 4
}

// MARK: - CGPoint Extensions
extension CGPoint {
    func normalized() -> CGPoint {
        let length = sqrt(x * x + y * y)
        guard length > 0 else { return self }
        return CGPoint(x: x / length, y: y / length)
    }

    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}