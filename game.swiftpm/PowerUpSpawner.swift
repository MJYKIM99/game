import Foundation
import SpriteKit

@MainActor
class PowerUpSpawner {

    // MARK: - Properties
    private weak var gameScene: GameScene?
    private var lastSpawnTime: TimeInterval = 0
    private var spawnInterval: TimeInterval = 8.0  // Spawn every 8 seconds initially

    // Spawn configuration
    private let minSpawnInterval: TimeInterval = 4.0
    private let maxSpawnInterval: TimeInterval = 12.0
    private var difficultyMultiplier: Float = 1.0

    // Spawn zones
    private var spawnZones: [CGRect] = []

    // MARK: - Initialization
    init(gameScene: GameScene) {
        self.gameScene = gameScene
        setupSpawnZones()
    }

    private func setupSpawnZones() {
        guard let scene = gameScene else { return }

        let margin: CGFloat = 50
        let zoneWidth: CGFloat = 150
        let zoneHeight: CGFloat = 150
        let sceneSize = scene.size

        // Create spawn zones in different areas of the screen
        spawnZones = [
            // Top-left zone
            CGRect(x: margin, y: sceneSize.height - margin - zoneHeight,
                   width: zoneWidth, height: zoneHeight),
            // Top-right zone
            CGRect(x: sceneSize.width - margin - zoneWidth, y: sceneSize.height - margin - zoneHeight,
                   width: zoneWidth, height: zoneHeight),
            // Bottom-left zone
            CGRect(x: margin, y: margin, width: zoneWidth, height: zoneHeight),
            // Bottom-right zone
            CGRect(x: sceneSize.width - margin - zoneWidth, y: margin,
                   width: zoneWidth, height: zoneHeight),
            // Center zones
            CGRect(x: margin, y: sceneSize.height/2 - zoneHeight/2, width: zoneWidth, height: zoneHeight),
            CGRect(x: sceneSize.width - margin - zoneWidth, y: sceneSize.height/2 - zoneHeight/2,
                   width: zoneWidth, height: zoneHeight)
        ]
    }

    // MARK: - Spawning Logic
    func update(currentTime: TimeInterval) {
        guard gameScene != nil else { return }

        // Check if it's time to spawn a new power-up
        if currentTime - lastSpawnTime >= spawnInterval {
            spawnPowerUp()
            lastSpawnTime = currentTime

            // Calculate next spawn interval with some randomness
            calculateNextSpawnInterval()
        }
    }

    private func calculateNextSpawnInterval() {
        // Base interval with randomness
        let baseInterval = Double.random(in: minSpawnInterval...maxSpawnInterval)

        // Apply difficulty multiplier (higher difficulty = more frequent spawns)
        let adjustedInterval = baseInterval / Double(difficultyMultiplier)

        spawnInterval = adjustedInterval
    }

    private func spawnPowerUp() {
        guard let scene = gameScene else { return }

        // Choose power-up type based on weights
        let powerUpType = choosePowerUpType()

        // Choose spawn location
        let spawnLocation = chooseSpawnLocation()

        // Create power-up entity
        let powerUp = PowerUpEntity(type: powerUpType)
        powerUp.position = spawnLocation

        // Add to scene
        scene.addChild(powerUp)

        print("Spawned \(powerUpType.displayName) at position: \(spawnLocation)")
    }

    private func choosePowerUpType() -> PowerUpType {
        // Calculate total weight
        let totalWeight = PowerUpType.allCases.reduce(0) { $0 + $1.spawnWeight }

        // Generate random number
        let random = Int.random(in: 0..<totalWeight)

        // Choose type based on weights
        var currentWeight = 0
        for type in PowerUpType.allCases {
            currentWeight += type.spawnWeight
            if random < currentWeight {
                return type
            }
        }

        // Fallback (shouldn't reach here)
        return PowerUpType.healthBoost
    }

    private func chooseSpawnLocation() -> CGPoint {
        guard let scene = gameScene else { return .zero }

        // Choose a random spawn zone
        let selectedZone = spawnZones.randomElement() ?? spawnZones.first!

        // Choose random position within the zone
        let x = CGFloat.random(in: selectedZone.minX...selectedZone.maxX)
        let y = CGFloat.random(in: selectedZone.minY...selectedZone.maxY)

        // Ensure position is within scene bounds
        let clampedX = max(20, min(scene.size.width - 20, x))
        let clampedY = max(20, min(scene.size.height - 20, y))

        return CGPoint(x: clampedX, y: clampedY)
    }

    // MARK: - Difficulty Management
    func setDifficulty(_ difficulty: Float) {
        difficultyMultiplier = difficulty

        // Adjust spawn intervals based on difficulty
        let newMinInterval = max(2.0, minSpawnInterval / Double(difficulty))
        let newMaxInterval = max(4.0, maxSpawnInterval / Double(difficulty))

        print("PowerUp spawner difficulty set to: \(difficulty) (interval: \(newMinInterval)-\(newMaxInterval)s)")
    }

    // MARK: - Control Methods
    func reset() {
        lastSpawnTime = 0
        spawnInterval = 8.0
        difficultyMultiplier = 1.0
    }

    func pause() {
        // Pausing logic handled by game scene
    }

    func resume() {
        // Resuming logic handled by game scene
    }

    // MARK: - Spawn Zone Management
    func updateSpawnZones() {
        setupSpawnZones()
    }

    // MARK: - Debug Methods
    func getSpawnInfo() -> [String: Any] {
        return [
            "lastSpawnTime": lastSpawnTime,
            "spawnInterval": spawnInterval,
            "difficultyMultiplier": difficultyMultiplier,
            "spawnZoneCount": spawnZones.count
        ]
    }

    func forceSpawnPowerUp(type: PowerUpType? = nil, at location: CGPoint? = nil) {
        guard let scene = gameScene else { return }

        let powerUpType = type ?? choosePowerUpType()
        let spawnLocation = location ?? chooseSpawnLocation()

        let powerUp = PowerUpEntity(type: powerUpType)
        powerUp.position = spawnLocation
        scene.addChild(powerUp)

        print("Force spawned \(powerUpType.displayName) at position: \(spawnLocation)")
    }
}