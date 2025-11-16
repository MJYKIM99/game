import Foundation
import SpriteKit

@MainActor
class PowerUpEffectManager: ObservableObject {

    // MARK: - Properties
    @Published var activePowerUps: [ActivePowerUp] = []
    @Published var powerUpEffects: PowerUpEffects = PowerUpEffects()

    private weak var player: Player?
    private weak var gameManager: GameManager?

    // Effect timers and tracking
    private var effectTimers: [Timer] = []

    // MARK: - PowerUpEffects Structure
    struct PowerUpEffects {
        var healthBoostMultiplier: Float = 1.0
        var fireRateMultiplier: Float = 1.0
        var damageReduction: Float = 0.0
        var hasShield: Bool = false

        var healthRestoration: Float = 0.0
        var extraDamage: Float = 0.0

        mutating func reset() {
            healthBoostMultiplier = 1.0
            fireRateMultiplier = 1.0
            damageReduction = 0.0
            hasShield = false
            healthRestoration = 0.0
            extraDamage = 0.0
        }
    }

    // MARK: - Initialization
    init(player: Player? = nil, gameManager: GameManager? = nil) {
        self.player = player
        self.gameManager = gameManager
    }

    func setupReferences(player: Player, gameManager: GameManager) {
        self.player = player
        self.gameManager = gameManager
    }

    // MARK: - PowerUp Application
    func applyPowerUp(_ type: PowerUpType) {
        switch type {
        case .healthBoost:
            applyHealthBoost()
        case .rapidFire:
            applyRapidFire()
        case .shield:
            applyShield()
        }

        // Create visual feedback
        createPickupEffect(for: type)
    }

    private func applyHealthBoost() {
        guard let player = player else { return }

        let healthToRestore = 30
        player.heal(amount: healthToRestore)

        // Notify game manager
        gameManager?.playerHealthUpdated(player.health)

        // Create healing effect
        createHealingEffect()

        print("Health boost applied! Health restored to \(player.health)")
    }

    private func applyRapidFire() {
        let powerUp = ActivePowerUp(type: .rapidFire) { [weak self] in
            self?.removePowerUp(type: .rapidFire)
        }
        activePowerUps.append(powerUp)

        // Track timer
        if let timer = powerUp.getTimer() {
            effectTimers.append(timer)
        }

        // Update fire rate
        recalculateEffects()

        // Create visual effect
        createRapidFireEffect()

        print("Rapid fire activated for 10 seconds!")
    }

    private func applyShield() {
        let powerUp = ActivePowerUp(type: .shield) { [weak self] in
            self?.removePowerUp(type: .shield)
        }
        activePowerUps.append(powerUp)

        // Track timer
        if let timer = powerUp.getTimer() {
            effectTimers.append(timer)
        }

        // Update shield status
        recalculateEffects()

        // Create shield visual effect
        createShieldEffect()

        print("Shield activated for 15 seconds!")
    }

    private func removePowerUp(type: PowerUpType) {
        activePowerUps.removeAll { $0.type == type }
        recalculateEffects()

        print("\(type.displayName) effect expired!")

        // Create expiration effect
        createExpirationEffect(for: type)
    }

    private func recalculateEffects() {
        powerUpEffects.reset()

        for powerUp in activePowerUps {
            switch powerUp.type {
            case .healthBoost:
                powerUpEffects.healthBoostMultiplier = 1.5

            case .rapidFire:
                powerUpEffects.fireRateMultiplier = 1.5
                powerUpEffects.extraDamage = 0.5

            case .shield:
                powerUpEffects.hasShield = true
                powerUpEffects.damageReduction = 1.0
            }
        }
    }

    // MARK: - Visual Effects
    private func createPickupEffect(for type: PowerUpType) {
        guard let player = player else { return }

        // Create pickup indicator
        let indicator = SKLabelNode(text: type.iconEmoji + " " + type.displayName)
        indicator.fontSize = 14
        indicator.fontColor = type.color
        indicator.position = CGPoint(x: 0, y: 30)
        indicator.zPosition = 1000
        player.addChild(indicator)

        // Animate indicator
        let animation = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 1.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        indicator.run(animation)
    }

    private func createHealingEffect() {
        guard let player = player else { return }

        // Create healing particles
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = .green
            particle.strokeColor = .clear
            particle.position = CGPoint(
                x: CGFloat.random(in: -15...15),
                y: CGFloat.random(in: -15...15)
            )
            particle.zPosition = 999
            player.addChild(particle)

            let animation = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.7),
                SKAction.removeFromParent()
            ])
            particle.run(animation)
        }

        // Flash effect
        let flash = SKAction.sequence([
            SKAction.colorize(with: .green, colorBlendFactor: 0.5, duration: 0.2),
            SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: 0.3)
        ])
        player.run(flash)
    }

    private func createRapidFireEffect() {
        guard let player = player else { return }

        // Create fire aura around player
        let fireAura = SKShapeNode(circleOfRadius: 25)
        fireAura.strokeColor = .orange
        fireAura.fillColor = .clear
        fireAura.lineWidth = 2
        fireAura.alpha = 0.7
        fireAura.zPosition = -1
        fireAura.name = "rapidFireAura"
        player.addChild(fireAura)

        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        fireAura.run(SKAction.repeatForever(pulse))

        // Rotate animation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 3.0)
        fireAura.run(SKAction.repeatForever(rotate))
    }

    private func createShieldEffect() {
        guard let player = player else { return }

        // Create shield bubble
        let shield = SKShapeNode(circleOfRadius: 30)
        shield.strokeColor = .blue
        shield.fillColor = .blue
        shield.alpha = 0.3
        shield.lineWidth = 3
        shield.zPosition = -1
        shield.name = "shield"
        player.addChild(shield)

        // Shield shimmer effect
        let shimmer = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.5),
            SKAction.fadeAlpha(to: 0.3, duration: 0.5)
        ])
        shield.run(SKAction.repeatForever(shimmer))

        // Hexagon pattern
        createShieldHexagonPattern(in: shield)
    }

    private func createShieldHexagonPattern(in shield: SKShapeNode) {
        let hexRadius: CGFloat = 8
        for i in 0..<6 {
            let angle = CGFloat(i) * CGFloat.pi / 3
            let x = cos(angle) * hexRadius
            let y = sin(angle) * hexRadius

            let hexVertex = SKShapeNode(circleOfRadius: 2)
            hexVertex.fillColor = .cyan
            hexVertex.strokeColor = .clear
            hexVertex.position = CGPoint(x: x, y: y)
            hexVertex.zPosition = 1
            shield.addChild(hexVertex)

            // Pulse vertex
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            hexVertex.run(SKAction.sequence([SKAction.wait(forDuration: Double(i) * 0.1), SKAction.repeatForever(pulse)]))
        }
    }

    private func createExpirationEffect(for type: PowerUpType) {
        guard let player = player else { return }

        // Remove corresponding visual effect
        switch type {
        case .rapidFire:
            player.childNode(withName: "rapidFireAura")?.removeFromParent()

        case .shield:
            player.childNode(withName: "shield")?.removeFromParent()

        case .healthBoost:
            // Health boost has no persistent visual effect
            break
        }

        // Create expiration indicator
        let indicator = SKLabelNode(text: "\(type.displayName) Expired!")
        indicator.fontSize = 12
        indicator.fontColor = .red
        indicator.position = CGPoint(x: 0, y: 30)
        indicator.zPosition = 1000
        player.addChild(indicator)

        let animation = SKAction.sequence([
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent()
        ])
        indicator.run(animation)
    }

    // MARK: - Combat Integration
    func modifyDamage(incomingDamage: Int) -> Int {
        guard powerUpEffects.hasShield else { return incomingDamage }

        let reduction = Float(incomingDamage) * powerUpEffects.damageReduction
        let modifiedDamage = Int(Float(incomingDamage) - reduction)

        return max(0, modifiedDamage)
    }

    func getFireRateMultiplier() -> Float {
        return powerUpEffects.fireRateMultiplier
    }

    func getProjectileDamageMultiplier() -> Float {
        return 1.0 + powerUpEffects.extraDamage
    }

    // MARK: - Cleanup
    func reset() {
        // Clear all active power-ups
        for powerUp in activePowerUps {
            powerUp.deactivate()
        }
        activePowerUps.removeAll()

        // Clear effects
        powerUpEffects.reset()

        // Remove visual effects from player
        player?.childNode(withName: "rapidFireAura")?.removeFromParent()
        player?.childNode(withName: "shield")?.removeFromParent()

        // Cancel all timers
        for timer in effectTimers {
            timer.invalidate()
        }
        effectTimers.removeAll()

        print("All power-up effects reset")
    }

    // MARK: - Debug Methods
    func debugPrintActiveEffects() {
        print("=== Active Power-Ups ===")
        for powerUp in activePowerUps {
            print("- \(powerUp.type.displayName): \(powerUp.timeRemaining)s remaining")
        }
        print("Fire Rate Multiplier: \(powerUpEffects.fireRateMultiplier)")
        print("Damage Reduction: \(powerUpEffects.damageReduction)")
        print("Has Shield: \(powerUpEffects.hasShield)")
        print("========================")
    }

    func forceActivatePowerUp(_ type: PowerUpType) {
        applyPowerUp(type)
    }
}