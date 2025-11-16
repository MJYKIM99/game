import SpriteKit

class CollisionDetector {

    // MARK: - Collision Detection
    static func checkCollision(_ contact: SKPhysicsContact) -> Collision {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        // 确定碰撞对象的类型
        let playerNode = bodyA.categoryBitMask == PhysicsCategory.player ? bodyA.node :
                         bodyB.categoryBitMask == PhysicsCategory.player ? bodyB.node : nil

        let enemyNode = bodyA.categoryBitMask == PhysicsCategory.enemy ? bodyA.node :
                        bodyB.categoryBitMask == PhysicsCategory.enemy ? bodyB.node : nil

        let playerProjectileNode = bodyA.categoryBitMask == PhysicsCategory.playerProjectile ? bodyA.node :
                                  bodyB.categoryBitMask == PhysicsCategory.playerProjectile ? bodyB.node : nil

        let enemyProjectileNode = bodyA.categoryBitMask == PhysicsCategory.enemyProjectile ? bodyA.node :
                                 bodyB.categoryBitMask == PhysicsCategory.enemyProjectile ? bodyB.node : nil

        let powerUpNode = bodyA.categoryBitMask == PhysicsCategory.powerUp ? bodyA.node :
                          bodyB.categoryBitMask == PhysicsCategory.powerUp ? bodyB.node : nil

        return Collision(
            player: playerNode as? Player,
            enemy: enemyNode as? Enemy,
            playerProjectile: playerProjectileNode as? Projectile,
            enemyProjectile: enemyProjectileNode as? Projectile,
            powerUp: powerUpNode as? PowerUpEntity
        )
    }
}

// MARK: - Collision Data Structure
struct Collision {

    // MARK: - Properties
    let player: Player?
    let enemy: Enemy?
    let playerProjectile: Projectile?
    let enemyProjectile: Projectile?
    let powerUp: PowerUpEntity?

    // MARK: - Convenience Properties
    var hasValidCollision: Bool {
        return player != nil || enemy != nil || playerProjectile != nil || enemyProjectile != nil || powerUp != nil
    }

    // MARK: - Collision Type Checks
    func containsPlayer() -> Bool {
        return player != nil
    }

    func containsEnemy() -> Bool {
        return enemy != nil
    }

    func containsPlayerProjectile() -> Bool {
        return playerProjectile != nil
    }

    func containsEnemyProjectile() -> Bool {
        return enemyProjectile != nil
    }

    func containsPowerUp() -> Bool {
        return powerUp != nil
    }

    // MARK: - Specific Collision Scenarios
    func isPlayerHitByEnemyProjectile() -> Bool {
        return player != nil && enemyProjectile != nil
    }

    func isEnemyHitByPlayerProjectile() -> Bool {
        return enemy != nil && playerProjectile != nil
    }

    func isPlayerAndEnemyCollision() -> Bool {
        return player != nil && enemy != nil
    }

    func isProjectileCollision() -> Bool {
        return playerProjectile != nil && enemyProjectile != nil
    }

    func isPlayerCollectsPowerUp() -> Bool {
        return player != nil && powerUp != nil
    }

    // MARK: - Debug Information
    func getCollisionDescription() -> String {
        var description = "Collision: "
        var components: [String] = []

        if player != nil { components.append("Player") }
        if enemy != nil { components.append("Enemy") }
        if playerProjectile != nil { components.append("Player Projectile") }
        if enemyProjectile != nil { components.append("Enemy Projectile") }
        if powerUp != nil { components.append("PowerUp") }

        if components.isEmpty {
            description += "Unknown"
        } else {
            description += components.joined(separator: " + ")
        }

        return description
    }
}

// MARK: - Collision Effects
@MainActor
extension CollisionDetector {

    // MARK: - Visual Effects
    static func createCollisionEffect(at position: CGPoint, type: CollisionType) -> SKNode {
        let effectNode = SKNode()
        effectNode.position = position

        switch type {
        case .playerHit:
            createPlayerHitEffect(parent: effectNode)
        case .enemyHit:
            createEnemyHitEffect(parent: effectNode)
        case .projectileImpact:
            createProjectileImpactEffect(parent: effectNode)
        case .shieldHit:
            createShieldHitEffect(parent: effectNode)
        case .powerUpCollect:
            createPowerUpCollectEffect(parent: effectNode)
        }

        return effectNode
    }

    private static func createPlayerHitEffect(parent: SKNode) {
        // 白色闪光效果
        let flash = SKShapeNode(circleOfRadius: 20)
        flash.fillColor = .white
        flash.strokeColor = .clear
        flash.alpha = 0.8

        let flashAnimation = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])

        parent.addChild(flash)
        flash.run(flashAnimation)

        // 火花效果
        createSparkEffect(parent: parent, particleCount: 8, color: .white)
    }

    private static func createEnemyHitEffect(parent: SKNode) {
        // 红色爆炸效果
        let explosion = SKShapeNode(circleOfRadius: 15)
        explosion.fillColor = .red
        explosion.strokeColor = .orange
        explosion.alpha = 0.9

        let explosionAnimation = SKAction.sequence([
            SKAction.scale(to: 2.0, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])

        parent.addChild(explosion)
        explosion.run(explosionAnimation)

        // 火花效果
        createSparkEffect(parent: parent, particleCount: 12, color: .red)
    }

    private static func createProjectileImpactEffect(parent: SKNode) {
        // 小型冲击波效果
        let impact = SKShapeNode(circleOfRadius: 8)
        impact.fillColor = .cyan
        impact.strokeColor = .white
        impact.alpha = 0.7

        let impactAnimation = SKAction.sequence([
            SKAction.scale(to: 1.8, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ])

        parent.addChild(impact)
        impact.run(impactAnimation)

        // 少量火花
        createSparkEffect(parent: parent, particleCount: 4, color: .cyan)
    }

    private static func createShieldHitEffect(parent: SKNode) {
        // 蓝色护盾效果
        let shield = SKShapeNode(circleOfRadius: 25)
        shield.fillColor = .clear
        shield.strokeColor = .blue
        shield.lineWidth = 3
        shield.alpha = 0.8

        let shieldAnimation = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ])

        parent.addChild(shield)
        shield.run(shieldAnimation)

        // 能量粒子
        createSparkEffect(parent: parent, particleCount: 6, color: .blue)
    }

    private static func createPowerUpCollectEffect(parent: SKNode) {
        // 彩色收集效果
        let ring1 = SKShapeNode(circleOfRadius: 10)
        ring1.fillColor = .clear
        ring1.strokeColor = .yellow
        ring1.lineWidth = 2
        ring1.alpha = 0.9

        let ring2 = SKShapeNode(circleOfRadius: 15)
        ring2.fillColor = .clear
        ring2.strokeColor = .orange
        ring2.lineWidth = 2
        ring2.alpha = 0.7

        let ring3 = SKShapeNode(circleOfRadius: 20)
        ring3.fillColor = .clear
        ring3.strokeColor = .red
        ring3.lineWidth = 2
        ring3.alpha = 0.5

        let expandAnimation = SKAction.sequence([
            SKAction.scale(to: 3.0, duration: 0.6),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ])

        parent.addChild(ring1)
        parent.addChild(ring2)
        parent.addChild(ring3)

        ring1.run(expandAnimation)
        ring2.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), expandAnimation]))
        ring3.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), expandAnimation]))

        // 彩色粒子爆发
        let colors: [SKColor] = [.yellow, .orange, .red, .green, .blue]
        for i in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = colors.randomElement() ?? .yellow
            particle.strokeColor = .clear
            particle.alpha = 1.0

            let angle = CGFloat(i) * CGFloat.pi * 2.0 / 20.0
            let distance = CGFloat.random(in: 20...50)
            let targetPosition = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )

            let particleAnimation = SKAction.sequence([
                SKAction.move(to: targetPosition, duration: 0.8),
                SKAction.fadeOut(withDuration: 0.4),
                SKAction.removeFromParent()
            ])

            particle.run(particleAnimation)
            parent.addChild(particle)
        }
    }

    private static func createSparkEffect(parent: SKNode, particleCount: Int, color: SKColor) {
        for i in 0..<particleCount {
            let spark = SKShapeNode(circleOfRadius: 2)
            spark.fillColor = color
            spark.strokeColor = .clear

            let angle = CGFloat(i) * CGFloat.pi * 2.0 / CGFloat(particleCount)
            let distance = CGFloat.random(in: 10...30)
            let targetPosition = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )

            let moveAction = SKAction.move(to: targetPosition, duration: 0.3)
            let fadeAction = SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3)
            ])
            let scaleAction = SKAction.sequence([
                SKAction.scale(to: 0.5, duration: 0.3)
            ])

            spark.run(SKAction.group([moveAction, fadeAction, scaleAction]))
            parent.addChild(spark)
        }
    }
}

// MARK: - Collision Types
enum CollisionType {
    case playerHit
    case enemyHit
    case projectileImpact
    case shieldHit
    case powerUpCollect
}

// MARK: - Physics Extensions
extension SKPhysicsContact {

    // MARK: - Collision Categories
    var isPlayerCollision: Bool {
        return bodyA.categoryBitMask == PhysicsCategory.player ||
               bodyB.categoryBitMask == PhysicsCategory.player
    }

    var isEnemyCollision: Bool {
        return bodyA.categoryBitMask == PhysicsCategory.enemy ||
               bodyB.categoryBitMask == PhysicsCategory.enemy
    }

    var isPlayerProjectileCollision: Bool {
        return bodyA.categoryBitMask == PhysicsCategory.playerProjectile ||
               bodyB.categoryBitMask == PhysicsCategory.playerProjectile
    }

    var isEnemyProjectileCollision: Bool {
        return bodyA.categoryBitMask == PhysicsCategory.enemyProjectile ||
               bodyB.categoryBitMask == PhysicsCategory.enemyProjectile
    }

    // MARK: - Get Collision Nodes
    func getPlayerNode() -> Player? {
        if bodyA.categoryBitMask == PhysicsCategory.player {
            return bodyA.node as? Player
        } else if bodyB.categoryBitMask == PhysicsCategory.player {
            return bodyB.node as? Player
        }
        return nil
    }

    func getEnemyNode() -> Enemy? {
        if bodyA.categoryBitMask == PhysicsCategory.enemy {
            return bodyA.node as? Enemy
        } else if bodyB.categoryBitMask == PhysicsCategory.enemy {
            return bodyB.node as? Enemy
        }
        return nil
    }

    func getPlayerProjectileNode() -> Projectile? {
        if bodyA.categoryBitMask == PhysicsCategory.playerProjectile {
            return bodyA.node as? Projectile
        } else if bodyB.categoryBitMask == PhysicsCategory.playerProjectile {
            return bodyB.node as? Projectile
        }
        return nil
    }

    func getEnemyProjectileNode() -> Projectile? {
        if bodyA.categoryBitMask == PhysicsCategory.enemyProjectile {
            return bodyA.node as? Projectile
        } else if bodyB.categoryBitMask == PhysicsCategory.enemyProjectile {
            return bodyB.node as? Projectile
        }
        return nil
    }
}