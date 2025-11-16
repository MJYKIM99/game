import SpriteKit

class Projectile: SKNode {

    // MARK: - Properties
    private let isPlayerProjectile: Bool
    private var projectileSprite: SKSpriteNode!
    private var projectileTrail: [SKSpriteNode] = []
    private var direction: CGPoint = .zero
    private let projectileSpeed: CGFloat = 8.0

    // 动画效果
    private var trailAnimation: SKAction?
    private var hitAnimation: SKAction?

    // MARK: - Initialization
    init(isPlayerProjectile: Bool) {
        self.isPlayerProjectile = isPlayerProjectile

        super.init()

        // 创建像素飞弹
        let projectileColor: SKColor = isPlayerProjectile ? .cyan : .red
        let trailColor: SKColor = isPlayerProjectile ? .blue : .orange

        projectileSprite = Projectile.createPixelBlock(width: 2, height: 4, color: projectileColor)

        setupProjectile()
        setupPhysics()
        setupAnimations(trailColor: trailColor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func createPixelBlock(width: Int, height: Int, color: SKColor) -> SKSpriteNode {
        let pixelSize: CGFloat = 3  // 飞弹稍微小一点
        let block = SKSpriteNode(color: color,
                               size: CGSize(width: pixelSize * CGFloat(width),
                                          height: pixelSize * CGFloat(height)))
        return block
    }

    private func setupProjectile() {
        // 主飞弹体
        projectileSprite.position = .zero
        addChild(projectileSprite)

        // 添加发光效果
        let glowNode = Projectile.createPixelBlock(width: 3, height: 5, color: isPlayerProjectile ? .white : .yellow)
        glowNode.alpha = 0.6
        glowNode.position = .zero
        addChild(glowNode)

        // 设置节点大小
        self.calculateAccumulatedFrame()
    }

    private func setupPhysics() {
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 8, height: 12))
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false

        if isPlayerProjectile {
            physicsBody.categoryBitMask = PhysicsCategory.playerProjectile
            physicsBody.contactTestBitMask = PhysicsCategory.enemy
        } else {
            physicsBody.categoryBitMask = PhysicsCategory.enemyProjectile
            physicsBody.contactTestBitMask = PhysicsCategory.player
        }

        physicsBody.collisionBitMask = PhysicsCategory.none
        self.physicsBody = physicsBody
    }

    private func setupAnimations(trailColor: SKColor) {
        // 创建轨迹动画
        createTrailEffect(color: trailColor)

        // 被击中动画
        let hitScale = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.1),
            SKAction.scale(to: 0.0, duration: 0.2),
            SKAction.removeFromParent()
        ])
        let hitFade = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])

        hitAnimation = SKAction.group([hitScale, hitFade])
    }

    private func createTrailEffect(color: SKColor) {
        // 创建轨迹粒子
        for i in 1..<4 {
            let trail = Projectile.createPixelBlock(width: 1, height: 1, color: color)
            trail.alpha = 0.8 - (0.2 * CGFloat(i))
            trail.position = CGPoint(x: 0, y: -CGFloat(i) * 4)
            addChild(trail)
            projectileTrail.append(trail)
        }

        // 轨迹动画
        trailAnimation = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.0, duration: 0.2),
            SKAction.fadeAlpha(to: 0.8, duration: 0.1)
        ])
    }

    // MARK: - Movement
    func setDirection(_ direction: CGPoint) {
        self.direction = direction.normalized()

        // 旋转飞弹以朝向移动方向
        let angle = atan2(direction.y, direction.x) + .pi / 2
        zRotation = angle
    }

    func update() {
        guard !direction.equalTo(.zero) else { return }

        // 更新位置
        let newPosition = CGPoint(
            x: position.x + direction.x * projectileSpeed,
            y: position.y + direction.y * projectileSpeed
        )
        position = newPosition

        // 更新轨迹效果
        updateTrail()
    }

    private func updateTrail() {
        // 为轨迹添加动画效果
        for (index, trail) in projectileTrail.enumerated() {
            if index < projectileTrail.count - 1 {
                trail.position = projectileTrail[index + 1].position
            } else {
                trail.position = CGPoint(x: 0, y: 0)
            }

            // 轨迹闪烁动画
            if index == projectileTrail.count - 1 {
                trail.run(trailAnimation!)
            }
        }
    }

    // MARK: - Collision Effects
    func hit() {
        // 停止移动
        direction = .zero

        // 创建击中效果
        createHitEffect()

        // 播放击中动画
        if let hitAnimation = hitAnimation {
            projectileSprite.run(hitAnimation)
        }

        // 移除轨迹
        for trail in projectileTrail {
            trail.removeFromParent()
        }
        projectileTrail.removeAll()
    }

    private func createHitEffect() {
        let particleCount = 6
        let particleColor: SKColor = isPlayerProjectile ? .cyan : .red

        for i in 0..<particleCount {
            let particle = Projectile.createPixelBlock(width: 1, height: 1, color: particleColor)
            particle.position = .zero

            let angle = CGFloat(i) * CGFloat.pi * 2.0 / CGFloat(particleCount)
            let distance = CGFloat.random(in: 10...20)
            let targetPosition = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )

            let moveAction = SKAction.move(to: targetPosition, duration: 0.2)
            let fadeAction = SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2)
            ])

            particle.run(SKAction.group([moveAction, fadeAction]))
            addChild(particle)
        }
    }

    // MARK: - Properties
    var size: CGSize {
        return CGSize(width: 8, height: 12)
    }

    // MARK: - Deinitialization
    deinit {
        // 清理资源
        projectileTrail.removeAll()
    }
}

// MARK: - Projectile Extensions
extension Projectile {

    // MARK: - Static Factory Methods
    static func createPlayerProjectile() -> Projectile {
        return Projectile(isPlayerProjectile: true)
    }

    static func createEnemyProjectile() -> Projectile {
        return Projectile(isPlayerProjectile: false)
    }
}