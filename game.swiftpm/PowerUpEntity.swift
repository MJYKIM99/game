import Foundation
import SpriteKit

class PowerUpEntity: SKNode {

    // MARK: - Properties
    let type: PowerUpType
    let data: PowerUpData
    private let creationTime: TimeInterval
    private let lifetime: TimeInterval = 15.0  // Power-up disappears after 15 seconds

    // Visual components
    private var powerUpSprite: SKSpriteNode!
    private var glowEffect: SKShapeNode!
    private var rotationAction: SKAction!
    private var pulseAction: SKAction!

    // Animation
    private var spawnAnimation: SKAction!
    private var floatAnimation: SKAction!

    // MARK: - Initialization
    init(type: PowerUpType) {
        self.type = type
        self.data = PowerUpData(type: type)
        self.creationTime = Date().timeIntervalSince1970

        super.init()

        setupVisuals()
        setupPhysics()
        setupAnimations()
        startAnimations()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Check
    func shouldDisappear(currentTime: TimeInterval) -> Bool {
        return currentTime - creationTime >= lifetime
    }

    // MARK: - Time Remaining
    func timeRemaining(currentTime: TimeInterval) -> TimeInterval {
        let elapsed = currentTime - creationTime
        return max(0, lifetime - elapsed)
    }

    // MARK: - Setup Methods
    private func setupVisuals() {
        // Create main power-up sprite
        let size: CGFloat = 24
        powerUpSprite = SKSpriteNode(color: type.color, size: CGSize(width: size, height: size))
        powerUpSprite.position = .zero
        addChild(powerUpSprite)

        // Create pixel art design based on type
        createPixelArtDesign()

        // Add glow effect
        createGlowEffect()

        // Add floating particles
        createFloatingParticles()
    }

    private func createPixelArtDesign() {
        // Clear existing design
        powerUpSprite.removeAllChildren()

        let pixelSize: CGFloat = 4
        let pattern = getPixelPattern()

        for (index, shouldCreatePixel) in pattern.enumerated() {
            if shouldCreatePixel {
                let pixel = SKSpriteNode(color: .white, size: CGSize(width: pixelSize, height: pixelSize))

                // Calculate position based on pattern index
                let row = index / 3
                let col = index % 3
                let x = CGFloat(col - 1) * pixelSize
                let y = CGFloat(row - 1) * pixelSize

                pixel.position = CGPoint(x: x, y: y)
                powerUpSprite.addChild(pixel)
            }
        }

        // Add icon overlay
        addIconOverlay()
    }

    private func getPixelPattern() -> [Bool] {
        switch type {
        case .healthBoost:
            // Cross pattern for health
            return [
                false, true, false,
                true,  true, true,
                false, true, false
            ]
        case .rapidFire:
            // Triangle pattern for fire
            return [
                false, true, false,
                true,  true, true,
                true,  false, true
            ]
        case .shield:
            // Diamond pattern for shield
            return [
                false, true, false,
                true,  true, true,
                false, true, false
            ]
        }
    }

    private func addIconOverlay() {
        let iconLabel = SKLabelNode(text: type.iconEmoji)
        iconLabel.fontSize = 16
        iconLabel.fontName = "Apple Color Emoji"
        iconLabel.position = CGPoint(x: 0, y: -2)
        iconLabel.zPosition = 10
        powerUpSprite.addChild(iconLabel)
    }

    private func createGlowEffect() {
        glowEffect = SKShapeNode(circleOfRadius: 20)
        glowEffect.position = .zero
        glowEffect.fillColor = type.color
        glowEffect.strokeColor = .clear
        glowEffect.alpha = 0.3
        glowEffect.zPosition = -1
        addChild(glowEffect)

        // Glow pulse animation
        let glowPulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        glowEffect.run(SKAction.repeatForever(glowPulse))
    }

    private func createFloatingParticles() {
        for _ in 0..<6 {
            let particle = SKShapeNode(circleOfRadius: 2)
            particle.fillColor = type.color
            particle.strokeColor = .clear
            particle.alpha = 0.6

            // Random position around the power-up
            let angle = CGFloat.random(in: 0...2*CGFloat.pi)
            let distance = CGFloat.random(in: 15...25)
            particle.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )

            // Orbit animation
            let orbit = SKAction.customAction(withDuration: 4.0) { node, elapsedTime in
                let currentAngle = angle + (elapsedTime / 4.0) * 2 * CGFloat.pi
                node.position = CGPoint(
                    x: cos(currentAngle) * distance,
                    y: sin(currentAngle) * distance
                )
            }

            particle.run(SKAction.repeatForever(orbit))
            addChild(particle)
        }
    }

    private func setupPhysics() {
        let physicsBody = SKPhysicsBody(circleOfRadius: 15)
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = PhysicsCategory.powerUp
        physicsBody.contactTestBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask = PhysicsCategory.none
        self.physicsBody = physicsBody
    }

    private func setupAnimations() {
        // Rotation animation
        rotationAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 4.0)

        // Pulse animation
        pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])

        // Spawn animation
        spawnAnimation = SKAction.sequence([
            SKAction.scale(to: 0.1, duration: 0),
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])

        // Float animation
        let floatUp = SKAction.moveBy(x: 0, y: 10, duration: 2.0)
        let floatDown = SKAction.moveBy(x: 0, y: -10, duration: 2.0)
        floatAnimation = SKAction.sequence([floatUp, floatDown])
    }

    private func startAnimations() {
        // Start spawn animation
        powerUpSprite.run(spawnAnimation)

        // Start continuous animations
        powerUpSprite.run(SKAction.repeatForever(rotationAction))
        powerUpSprite.run(SKAction.repeatForever(pulseAction))
        run(SKAction.repeatForever(floatAnimation))
    }

    // MARK: - Effects
    func collectEffect() {
        // Create collection effect
        createCollectionEffect()
    }

    private func createCollectionEffect() {
        // Create expanding ring effect
        let ring = SKShapeNode(circleOfRadius: 5)
        ring.position = .zero
        ring.strokeColor = type.color
        ring.fillColor = .clear
        ring.lineWidth = 3
        ring.zPosition = 100
        addChild(ring)

        let expandAndFade = SKAction.sequence([
            SKAction.scale(to: 3.0, duration: 0.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        ring.run(expandAndFade)

        // Create particle burst
        createParticleBurst()
    }

    private func createParticleBurst() {
        for _ in 0..<12 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = type.color
            particle.strokeColor = .clear
            particle.position = .zero
            particle.zPosition = 99
            addChild(particle)

            let angle = CGFloat.random(in: 0...2*CGFloat.pi)
            let distance = CGFloat.random(in: 30...60)
            let targetPosition = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )

            let particleAnimation = SKAction.sequence([
                SKAction.move(to: targetPosition, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.4),
                SKAction.removeFromParent()
            ])
            particle.run(particleAnimation)
        }
    }

    // MARK: - Cleanup
    func disappear() {
        let fadeOut = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])
        run(fadeOut)
    }

    // MARK: - Properties
    var size: CGSize {
        return CGSize(width: 30, height: 30)
    }
}