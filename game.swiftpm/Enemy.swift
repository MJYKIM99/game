import SpriteKit

class Enemy: SKNode {

    // MARK: - Properties
    private var maxHealth: Int = 40
    private(set) var health: Int = 40
    var isAlive: Bool = true
    private var sprite: SKNode

    // 移动属性 (adjusted for easier difficulty)
    private var moveSpeed: CGFloat = 1.0  // Slower enemy movement
    private let rotationSpeed: CGFloat = 0.05

    // 像素敌机设计
    private var enemyBody: SKSpriteNode!
    private var enemyCockpit: SKSpriteNode!
    private var enemyWeapon: SKSpriteNode!
    private var enemyWing1: SKSpriteNode!
    private var enemyWing2: SKSpriteNode!

    // 动画效果
    private var engineAnimation: SKAction?
    private var hitAnimation: SKAction?
    private var explosionAnimation: SKAction?

    override init() {
        // 创建容器精灵
        sprite = SKNode()
        sprite.position = .zero

        super.init()

        // 创建像素敌机各部分 (在super.init()之后调用)
        enemyBody = Enemy.createPixelBlock(width: 3, height: 4, color: .orange)  // 使用橙色让敌人更明显
        enemyCockpit = Enemy.createPixelBlock(width: 2, height: 2, color: .purple)
        enemyWeapon = Enemy.createPixelBlock(width: 1, height: 3, color: .red)
        enemyWing1 = Enemy.createPixelBlock(width: 3, height: 1, color: .magenta)
        enemyWing2 = Enemy.createPixelBlock(width: 3, height: 1, color: .magenta)

        setupShip()
        setupPhysics()
        setupAnimations()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func createPixelBlock(width: Int, height: Int, color: SKColor) -> SKSpriteNode {
        let pixelSize: CGFloat = 4  // 增大像素尺寸使其更可见
        let block = SKSpriteNode(color: color,
                               size: CGSize(width: pixelSize * CGFloat(width),
                                          height: pixelSize * CGFloat(height)))
        return block
    }

    private func setupShip() {
        // 机身主体
        enemyBody.position = .zero
        sprite.addChild(enemyBody)

        // 座舱
        enemyCockpit.position = CGPoint(x: 0, y: 6)
        sprite.addChild(enemyCockpit)

        // 武器系统
        enemyWeapon.position = CGPoint(x: 0, y: -8)
        sprite.addChild(enemyWeapon)

        // 上翼
        enemyWing1.position = CGPoint(x: 0, y: 4)
        sprite.addChild(enemyWing1)

        // 下翼
        enemyWing2.position = CGPoint(x: 0, y: -4)
        sprite.addChild(enemyWing2)

        // 将整个敌机添加到节点
        addChild(sprite)

        // 设置节点大小
        self.calculateAccumulatedFrame()
    }

    private func setupPhysics() {
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 16))
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = PhysicsCategory.enemy
        physicsBody.contactTestBitMask = PhysicsCategory.playerProjectile
        physicsBody.collisionBitMask = PhysicsCategory.none
        self.physicsBody = physicsBody
    }

    private func setupAnimations() {
        // 引擎闪烁动画（红色调）
        let enginePulse = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.3),
            SKAction.colorize(with: .gray, colorBlendFactor: 1.0, duration: 0.4)
        ])
        engineAnimation = SKAction.repeatForever(enginePulse)

        enemyWeapon.run(engineAnimation!)

        // 被击中闪烁动画
        let flashRed = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: 0.1)
        ])
        hitAnimation = SKAction.sequence([
            flashRed,
            flashRed,
            flashRed
        ])

        // 爆炸动画
        explosionAnimation = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.1),
            SKAction.scale(to: 0.1, duration: 0.3),
            SKAction.removeFromParent()
        ])
    }

    // MARK: - Game Logic
    func takeDamage() {
        takeDamage(damage: 20)
    }

    func takeDamage(damage: Int) {
        health -= damage

        // 播放被击中动画
        if let hitAnimation = hitAnimation {
            sprite.run(hitAnimation)
        }

        // 震动效果
        let shakeAction = SKAction.sequence([
            SKAction.moveBy(x: 1, y: 0, duration: 0.05),
            SKAction.moveBy(x: -2, y: 0, duration: 0.1),
            SKAction.moveBy(x: 1, y: 0, duration: 0.05)
        ])
        run(shakeAction)

        // 创建伤害效果
        let damageEffect = createDamageEffect()
        sprite.addChild(damageEffect)

        if health <= 0 && isAlive {
            isAlive = false
            explode()
        }
    }

    private func createDamageEffect() -> SKNode {
        let damageEffect = SKNode()

        // 添加火花粒子效果
        for _ in 0..<3 {
            let spark = Enemy.createPixelBlock(width: 1, height: 1, color: .red)
            spark.position = CGPoint(x: CGFloat.random(in: -6...6),
                                   y: CGFloat.random(in: -6...6))

            let sparkAnimation = SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.05),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ])

            spark.run(sparkAnimation)
            damageEffect.addChild(spark)
        }

        return damageEffect
    }

    private func explode() {
        // 停止正常动画
        sprite.removeAllActions()

        // 创建爆炸效果
        createExplosionParticles()

        // 播放爆炸动画
        if let explosionAnimation = explosionAnimation {
            sprite.run(explosionAnimation)
        }
    }

    private func createExplosionParticles() {
        let particleCount = 8
        for i in 0..<particleCount {
            let particle = Enemy.createPixelBlock(width: 2, height: 2, color: .red)
            particle.position = sprite.position

            let angle = CGFloat(i) * CGFloat.pi * 2.0 / CGFloat(particleCount)
            let distance = CGFloat.random(in: 20...40)
            let targetPosition = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )

            let moveAction = SKAction.move(to: targetPosition, duration: 0.3)
            let fadeAction = SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3)
            ])

            particle.run(SKAction.group([moveAction, fadeAction]))
            sprite.addChild(particle)
        }
    }

    // MARK: - Movement
    func move(towards playerPosition: CGPoint) {
        guard isAlive else { return }

        let direction = CGPoint(x: playerPosition.x - position.x,
                              y: playerPosition.y - position.y)
        let normalizedDirection = direction.normalized()

        let newPosition = CGPoint(
            x: position.x + normalizedDirection.x * moveSpeed,
            y: position.y + normalizedDirection.y * moveSpeed
        )

        position = newPosition

        // 旋转以朝向玩家
        let targetAngle = atan2(normalizedDirection.y, normalizedDirection.x) - .pi / 2
        let currentAngle = sprite.zRotation
        let angleDifference = targetAngle - currentAngle

        // 平滑旋转
        sprite.zRotation += angleDifference * rotationSpeed
    }

    // MARK: - Difficulty Scaling
    func setDifficulty(level: Int) {
        // 根据难度等级调整敌机属性
        maxHealth = 40 + (level * 10)
        health = maxHealth
        moveSpeed = min(4.0, 1.5 + CGFloat(level) * 0.3)

        // 调整颜色以表示难度
        if level > 5 {
            enemyBody.color = .black
            enemyWeapon.color = .red
        } else if level > 3 {
            enemyBody.color = .darkGray
        }
    }

    // MARK: - Properties
    var size: CGSize {
        return CGSize(width: 24, height: 24)
    }

    // MARK: - Health
    var healthPercentage: Float {
        return Float(health) / Float(maxHealth)
    }
}

// CGPoint extension is already defined in PhysicsConstants.swift