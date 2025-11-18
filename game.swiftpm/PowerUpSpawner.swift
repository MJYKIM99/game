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

    // MARK: - Initialization
    init(gameScene: GameScene) {
        self.gameScene = gameScene
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

        // Add to game scene's powerUps array for lifecycle management
        scene.addPowerUp(powerUp)

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
        guard let scene = gameScene, let player = scene.player else { return .zero }

        // Get player position
        let playerPosition = player.position

        // Define distance range from player (not too close, not too far)
        // Values chosen to make power-ups reachable but not right on top of player
        let minDistanceFromPlayer: CGFloat = 150  // Minimum 150 points
        let maxDistanceFromPlayer: CGFloat = 400  // Maximum 400 points

        // Generate random angle (0 to 2π)
        let randomAngle = CGFloat.random(in: 0...(2 * .pi))

        // Generate random distance within range
        let distance = CGFloat.random(in: minDistanceFromPlayer...maxDistanceFromPlayer)

        // Calculate potential spawn position using polar coordinates
        let potentialX = playerPosition.x + cos(randomAngle) * distance
        let potentialY = playerPosition.y + sin(randomAngle) * distance

        // Create margins from screen edges
        let margin: CGFloat = 50

        // Ensure position is within scene bounds with margins
        let clampedX = max(margin, min(scene.size.width - margin, potentialX))
        let clampedY = max(margin, min(scene.size.height - margin, potentialY))

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

    // MARK: - Debug Methods
    func getSpawnInfo() -> [String: Any] {
        return [
            "lastSpawnTime": lastSpawnTime,
            "spawnInterval": spawnInterval,
            "difficultyMultiplier": difficultyMultiplier
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