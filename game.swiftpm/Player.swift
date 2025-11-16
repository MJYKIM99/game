import SpriteKit

class Player: SKNode {

    // MARK: - Properties
    private let maxHealth = 100
    private(set) var health: Int = 100

    // 像素飞艇设计
    private var shipBody: SKSpriteNode!
    private var shipCockpit: SKSpriteNode!
    private var shipEngine1: SKSpriteNode!
    private var shipEngine2: SKSpriteNode!
    private var shipWing: SKSpriteNode!

    // 动画效果
    private var engineAnimation: SKAction?
    private var hitAnimation: SKAction?

    override init() {
        super.init()

        // 创建像素飞艇各部分 (在super.init()之后调用)
        shipBody = Player.createPixelBlock(width: 4, height: 6, color: .green)  // 使用更明显的绿色
        shipCockpit = Player.createPixelBlock(width: 2, height: 2, color: .blue)
        shipEngine1 = Player.createPixelBlock(width: 2, height: 3, color: .red)
        shipEngine2 = Player.createPixelBlock(width: 2, height: 3, color: .red)
        shipWing = Player.createPixelBlock(width: 8, height: 2, color: .yellow)

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
        // 清除所有现有子节点
        self.removeAllChildren()

        // 机身主体
        shipBody.position = .zero
        addChild(shipBody)

        // 座舱
        shipCockpit.position = CGPoint(x: 0, y: 8)
        addChild(shipCockpit)

        // 左引擎
        shipEngine1.position = CGPoint(x: -8, y: -6)
        addChild(shipEngine1)

        // 右引擎
        shipEngine2.position = CGPoint(x: 8, y: -6)
        addChild(shipEngine2)

        // 机翼
        shipWing.position = CGPoint(x: 0, y: 0)
        addChild(shipWing)

        // 设置节点大小
        self.calculateAccumulatedFrame()

        print("Player ship setup complete with \(self.children.count) children")
        print("Ship sizes - Body: \(shipBody.size), Cockpit: \(shipCockpit.size)")
    }

    private func setupPhysics() {
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 20))
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = PhysicsCategory.player
        physicsBody.contactTestBitMask = PhysicsCategory.enemyProjectile
        physicsBody.collisionBitMask = PhysicsCategory.none
        self.physicsBody = physicsBody
    }

    private func setupAnimations() {
        // 引擎闪烁动画
        let enginePulse = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 0.2),
            SKAction.colorize(with: .gray, colorBlendFactor: 1.0, duration: 0.3)
        ])
        engineAnimation = SKAction.repeatForever(enginePulse)

        shipEngine1.run(engineAnimation!)
        shipEngine2.run(engineAnimation!)

        // 被击中闪烁动画
        let flashWhite = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: 0.1)
        ])
        hitAnimation = SKAction.sequence([
            flashWhite,
            flashWhite,
            flashWhite
        ])
    }

    // MARK: - Game Logic
    func takeDamage() {
        health -= 20

        // 播放被击中动画
        if let hitAnimation = hitAnimation {
            shipBody.run(hitAnimation)
        }

        // 震动效果
        let shakeAction = SKAction.sequence([
            SKAction.moveBy(x: 2, y: 0, duration: 0.05),
            SKAction.moveBy(x: -4, y: 0, duration: 0.1),
            SKAction.moveBy(x: 2, y: 0, duration: 0.05)
        ])
        self.run(shakeAction)

        // 健康值低时的视觉反馈
        if health <= Int(Double(maxHealth) * 0.3) {
            // 显示损坏效果
            let damageEffect = createDamageEffect()
            addChild(damageEffect)
        }
    }

    private func createDamageEffect() -> SKNode {
        let damageEffect = SKNode()

        // 添加火花粒子效果
        let spark = Player.createPixelBlock(width: 1, height: 1, color: .red)
        spark.position = CGPoint(x: CGFloat.random(in: -10...10),
                               y: CGFloat.random(in: -10...10))

        let sparkAnimation = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])

        spark.run(sparkAnimation)
        damageEffect.addChild(spark)

        return damageEffect
    }

    func reset() {
        health = maxHealth

        // 重新创建飞船部件
        shipBody = Player.createPixelBlock(width: 4, height: 6, color: .green)  // 使用更明显的绿色
        shipCockpit = Player.createPixelBlock(width: 2, height: 2, color: .blue)
        shipEngine1 = Player.createPixelBlock(width: 2, height: 3, color: .red)
        shipEngine2 = Player.createPixelBlock(width: 2, height: 3, color: .red)
        shipWing = Player.createPixelBlock(width: 8, height: 2, color: .yellow)

        // 重新设置飞船 (setupShip会清理并重新添加)
        setupShip()

        // 重置动画
        if let engineAnimation = engineAnimation {
            shipEngine1.run(engineAnimation)
            shipEngine2.run(engineAnimation)
        }
    }

    // MARK: - Movement
    func move(to position: CGPoint) {
        let moveAction = SKAction.move(to: position, duration: 0.1)
        run(moveAction)
    }

    // MARK: - Properties
    var size: CGSize {
        return CGSize(width: 32, height: 32)
    }

    // MARK: - Health
    var healthPercentage: Float {
        return Float(health) / Float(maxHealth)
    }
}

// MARK: - Physics Categories
extension PhysicsCategory {
    // 定义已在 PhysicsConstants.swift 中完成
}