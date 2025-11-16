import SpriteKit

@MainActor
class GameScene: SKScene {

    // MARK: - Game Properties
    private var player: Player!
    private var enemies: [Enemy] = []
    private var playerProjectiles: [Projectile] = []
    private var enemyProjectiles: [Projectile] = []

    // Game timing
    private var lastEnemySpawn: TimeInterval = 0
    private var lastEnemyShot: TimeInterval = 0
    private var enemySpawnInterval: TimeInterval = 2.0
    private var enemyShotInterval: TimeInterval = 1.5

    // Game state
    private var isGameRunning = false
    private var joystickDirection: CGPoint = .zero

    weak var gameManager: GameManager?

    override func didMove(to view: SKView) {
        print("GameScene didMove to view, scene size: \(size)")
        setupScene()
        createPlayer()

        // 立即开始游戏用于测试
        isGameRunning = true
        print("Game started immediately for testing")
    }

    private func setupScene() {
        backgroundColor = SKColor.black
        scaleMode = .resizeFill

        // 添加星空背景效果
        createStarfieldBackground()

        // 设置物理世界
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        print("GameScene setup complete, size: \(size)")
    }

    private func createStarfieldBackground() {
        // 创建简单的星空背景
        for _ in 0..<50 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2))
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.3...1.0)

            // 添加闪烁动画
            let fadeAction = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 1...3)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 1...3))
            ])
            star.run(SKAction.repeatForever(fadeAction))

            addChild(star)
        }

        // 暂时移除复古视觉效果以确保游戏对象可见
        // VisualEffectsManager.applyRetroEffects(to: self)
    }

    private func createPlayer() {
        player = Player()
        let centerPosition = CGPoint(x: size.width / 2, y: size.height / 2)
        player.position = centerPosition
        addChild(player)

        print("Player created at position: \(centerPosition)")
        print("Player children count: \(player.children.count)")

        // 添加测试用的巨大彩色方块
        let testBlock = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        testBlock.position = centerPosition
        testBlock.zPosition = 1000  // 确保在最前面
        addChild(testBlock)
        print("Test block added at position: \(centerPosition)")
    }

    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard isGameRunning else { return }

        // 更新玩家移动
        updatePlayerMovement()

        // 生成敌人
        spawnEnemyIfNeeded(currentTime: currentTime)

        // 敌人射击
        enemyShootIfNeeded(currentTime: currentTime)

        // 更新所有游戏对象
        updateGameObjects()

        // 检查游戏边界
        checkGameBoundaries()
    }

    private func updatePlayerMovement() {
        guard let player = player else { return }

        let moveSpeed: CGFloat = 4.0
        let newPosition = CGPoint(
            x: player.position.x + joystickDirection.x * moveSpeed,
            y: player.position.y + joystickDirection.y * moveSpeed
        )

        // 限制在屏幕范围内
        let clampedPosition = CGPoint(
            x: max(player.size.width/2, min(size.width - player.size.width/2, newPosition.x)),
            y: max(player.size.height/2, min(size.height - player.size.height/2, newPosition.y))
        )

        player.position = clampedPosition
    }

    private func spawnEnemyIfNeeded(currentTime: TimeInterval) {
        if currentTime - lastEnemySpawn > enemySpawnInterval {
            spawnEnemy()
            lastEnemySpawn = currentTime

            // 逐渐增加生成频率（递增难度）
            enemySpawnInterval = max(0.8, enemySpawnInterval * 0.98)
        }
    }

    private func spawnEnemy() {
        let enemy = Enemy()

        // 确保有足够的空间生成敌人
        let minX = min(50, size.width * 0.1)
        let maxX = max(size.width - 50, size.width * 0.9)
        let minY = min(50, size.height * 0.1)
        let maxY = max(size.height - 50, size.height * 0.9)

        // 从屏幕边缘随机位置生成
        let spawnSide = Int.random(in: 0...3)
        switch spawnSide {
        case 0: // 上边
            enemy.position = CGPoint(x: CGFloat.random(in: minX...maxX), y: size.height + 50)
        case 1: // 右边
            enemy.position = CGPoint(x: size.width + 50, y: CGFloat.random(in: minY...maxY))
        case 2: // 下边
            enemy.position = CGPoint(x: CGFloat.random(in: minX...maxX), y: -50)
        default: // 左边
            enemy.position = CGPoint(x: -50, y: CGFloat.random(in: minY...maxY))
        }

        addChild(enemy)
        enemies.append(enemy)
    }

    private func enemyShootIfNeeded(currentTime: TimeInterval) {
        if currentTime - lastEnemyShot > enemyShotInterval {
            for enemy in enemies {
                if enemy.isAlive && Bool.random() {
                    enemyShoot(from: enemy)
                }
            }
            lastEnemyShot = currentTime

            // 逐渐增加射击频率（递增难度）
            enemyShotInterval = max(0.5, enemyShotInterval * 0.99)
        }
    }

    private func enemyShoot(from enemy: Enemy) {
        guard let player = player else { return }

        let projectile = Projectile(isPlayerProjectile: false)
        projectile.position = enemy.position

        // 计算朝向玩家的方向
        let direction = CGPoint(x: player.position.x - enemy.position.x,
                              y: player.position.y - enemy.position.y)
        let normalizedDirection = direction.normalized()

        projectile.setDirection(normalizedDirection)
        addChild(projectile)
        enemyProjectiles.append(projectile)
    }

    private func updateGameObjects() {
        // 更新敌人
        for enemy in enemies {
            enemy.move(towards: player.position)
        }

        // 更新飞弹
        for projectile in playerProjectiles {
            projectile.update()
        }

        for projectile in enemyProjectiles {
            projectile.update()
        }
    }

    private func checkGameBoundaries() {
        // 移除超出屏幕范围的敌人
        enemies = enemies.filter { enemy in
            if !enemy.isAlive {
                enemy.removeFromParent()
                return false
            }
            return true
        }

        // 移除超出屏幕范围的飞弹
        playerProjectiles = playerProjectiles.filter { projectile in
            if !isInBounds(projectile.position) {
                projectile.removeFromParent()
                return false
            }
            return true
        }

        enemyProjectiles = enemyProjectiles.filter { projectile in
            if !isInBounds(projectile.position) {
                projectile.removeFromParent()
                return false
            }
            return true
        }
    }

    private func isInBounds(_ position: CGPoint) -> Bool {
        return position.x >= -50 && position.x <= size.width + 50 &&
               position.y >= -50 && position.y <= size.height + 50
    }

    // MARK: - Input Handling
    func setJoystickDirection(_ direction: CGPoint) {
        joystickDirection = direction
    }

    func playerShoot(at targetPoint: CGPoint) {
        guard let player = player else { return }

        let projectile = Projectile(isPlayerProjectile: true)
        projectile.position = player.position

        // 计算射击方向
        let direction = CGPoint(x: targetPoint.x - player.position.x,
                              y: targetPoint.y - player.position.y)
        let normalizedDirection = direction.normalized()

        projectile.setDirection(normalizedDirection)
        addChild(projectile)
        playerProjectiles.append(projectile)
    }

    // MARK: - Game Control
    func startGame() {
        isGameRunning = true
    }

    func stopGame() {
        isGameRunning = false
    }

    func resetGame() {
        stopGame()

        // 清除所有游戏对象
        for enemy in enemies {
            enemy.removeFromParent()
        }
        enemies.removeAll()

        for projectile in playerProjectiles {
            projectile.removeFromParent()
        }
        playerProjectiles.removeAll()

        for projectile in enemyProjectiles {
            projectile.removeFromParent()
        }
        enemyProjectiles.removeAll()

        // 重置游戏参数
        enemySpawnInterval = 2.0
        enemyShotInterval = 1.5
        lastEnemySpawn = 0
        lastEnemyShot = 0
        joystickDirection = .zero

        // 重置玩家
        player?.reset()
        player?.position = CGPoint(x: size.width / 2, y: size.height / 2)

        startGame()
    }
}

// MARK: - Contact Delegate
extension GameScene: SKPhysicsContactDelegate {
    nonisolated func didBegin(_ contact: SKPhysicsContact) {
        let collision = CollisionDetector.checkCollision(contact)

        // 在主线程上处理碰撞逻辑
        Task { @MainActor in
            if collision.containsPlayer() && collision.containsEnemyProjectile() {
                // 玩家被击中
                self.player?.takeDamage()
                collision.enemyProjectile?.removeFromParent()
                self.enemyProjectiles.removeAll { $0 == collision.enemyProjectile }

                if let playerHealth = self.player?.health {
                    self.gameManager?.playerHealthUpdated(playerHealth)
                }

                if let playerHealth = self.player?.health, playerHealth <= 0 {
                    self.gameManager?.gameOver()
                }
            }

            if collision.containsEnemy() && collision.containsPlayerProjectile() {
                // 敌人被击中
                collision.enemy?.takeDamage()
                collision.playerProjectile?.removeFromParent()
                self.playerProjectiles.removeAll { $0 == collision.playerProjectile }

                if let enemyHealth = collision.enemy?.health, enemyHealth <= 0 {
                    collision.enemy?.isAlive = false
                    collision.enemy?.removeFromParent()
                    self.enemies.removeAll { $0 == collision.enemy }

                    self.gameManager?.enemyDestroyed()
                }
            }
        }
    }
}