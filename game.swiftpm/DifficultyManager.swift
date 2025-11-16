import Foundation

class DifficultyManager: ObservableObject {

    // MARK: - Difficulty Properties
    @Published var currentLevel: Int = 1
    @Published var score: Int = 0
    @Published var enemiesDestroyed: Int = 0
    @Published var gameTime: TimeInterval = 0

    // Difficulty scaling parameters
    private var baseEnemySpawnInterval: TimeInterval = 2.0
    private var baseEnemyShotInterval: TimeInterval = 1.5
    private var baseEnemySpeed: CGFloat = 1.5
    private var baseEnemyHealth: Int = 40

    // Level progression thresholds
    private let scorePerLevel = 100
    private let timeBonusPerLevel = 30.0 // seconds

    // MARK: - Initialization
    init() {
        resetDifficulty()
    }

    // MARK: - Difficulty Progression
    func updateDifficulty(score: Int, timePlayed: TimeInterval, enemiesDestroyed: Int) {
        self.score = score
        self.gameTime = timePlayed
        self.enemiesDestroyed = enemiesDestroyed

        // Calculate level based on multiple factors
        let scoreLevel = calculateLevelFromScore()
        let timeLevel = calculateLevelFromTime()
        let combatLevel = calculateLevelFromCombat()

        // Take the highest level reached
        let newLevel = max(scoreLevel, max(timeLevel, combatLevel))

        if newLevel != currentLevel {
            levelUp(to: newLevel)
        }
    }

    private func calculateLevelFromScore() -> Int {
        return (score / scorePerLevel) + 1
    }

    private func calculateLevelFromTime() -> Int {
        return Int(gameTime / timeBonusPerLevel) + 1
    }

    private func calculateLevelFromCombat() -> Int {
        return (enemiesDestroyed / 10) + 1
    }

    private func levelUp(to newLevel: Int) {
        guard newLevel > currentLevel else { return }

        let previousLevel = currentLevel
        currentLevel = newLevel

        print("Level Up! From level \(previousLevel) to \(newLevel)")

        // Level up effects could be triggered here
        NotificationCenter.default.post(
            name: .difficultyLevelUp,
            object: nil,
            userInfo: ["newLevel": newLevel]
        )
    }

    // MARK: - Difficulty Parameters
    func getEnemySpawnInterval() -> TimeInterval {
        let reduction = Double(currentLevel - 1) * 0.15 // 15% reduction per level
        let newInterval = baseEnemySpawnInterval * (1.0 - reduction)
        return max(0.3, newInterval) // Minimum 0.3 second spawn interval
    }

    func getEnemyShotInterval() -> TimeInterval {
        let reduction = Double(currentLevel - 1) * 0.12 // 12% reduction per level
        let newInterval = baseEnemyShotInterval * (1.0 - reduction)
        return max(0.4, newInterval) // Minimum 0.4 second shot interval
    }

    func getEnemySpeed() -> CGFloat {
        let increase = CGFloat(currentLevel - 1) * 0.25 // 25% increase per level
        let newSpeed = baseEnemySpeed * (1.0 + increase)
        return min(8.0, newSpeed) // Maximum speed limit
    }

    func getEnemyHealth() -> Int {
        let increase = (currentLevel - 1) * 10 // 10 health per level
        return baseEnemyHealth + increase
    }

    func getEnemyDamage() -> Int {
        return min(40, 20 + (currentLevel - 1) * 3) // Start at 20, +3 per level, max 40
    }

    func getEnemyCount() -> Int {
        // Increase max enemy count based on level
        return min(10, 2 + (currentLevel - 1) / 2)
    }

    // MARK: - Score Calculation
    func calculateScore(for enemy: Enemy) -> Int {
        // Base score varies by enemy difficulty
        let baseScore = 10

        // Level multiplier
        let levelMultiplier = currentLevel

        // Speed bonus (faster enemies worth more)
        let speedBonus = Int(enemy.position.distance(to: .zero)) / 10

        // Combo potential (could be expanded)
        let comboMultiplier = min(3.0, 1.0 + Double(enemiesDestroyed % 10) * 0.1)

        let totalScore = Int((Double(baseScore + speedBonus) * Double(levelMultiplier) * comboMultiplier))
        return totalScore
    }

    func calculateSurvivalBonus() -> Int {
        // Points for surviving time
        let timePoints = Int(gameTime * 2) // 2 points per second

        // Health bonus (if player has good health)
        // This would need player health access

        return timePoints
    }

    // MARK: - Game Balance Adjustments
    func adjustDifficultyBasedOnPerformance() {
        // Dynamic difficulty adjustment based on player performance
        let performanceRatio = calculatePerformanceRatio()

        if performanceRatio > 1.5 {
            // Player doing very well, increase difficulty slightly
            increaseDifficulty(adjustment: 0.1)
        } else if performanceRatio < 0.5 {
            // Player struggling, decrease difficulty slightly
            decreaseDifficulty(adjustment: 0.05)
        }
    }

    private func calculatePerformanceRatio() -> Double {
        // Simple performance metric: enemies destroyed per unit time
        guard gameTime > 0 else { return 1.0 }

        let destructionRate = Double(enemiesDestroyed) / gameTime
        let expectedRate = 0.5 // Expected: 1 enemy per 2 seconds

        return destructionRate / expectedRate
    }

    private func increaseDifficulty(adjustment: Double) {
        // Slightly increase difficulty parameters
        baseEnemySpawnInterval *= (1.0 - adjustment)
        baseEnemyShotInterval *= (1.0 - adjustment)
    }

    private func decreaseDifficulty(adjustment: Double) {
        // Slightly decrease difficulty parameters
        baseEnemySpawnInterval *= (1.0 + adjustment)
        baseEnemyShotInterval *= (1.0 + adjustment)
    }

    // MARK: - Reset and Management
    func resetDifficulty() {
        currentLevel = 1
        score = 0
        enemiesDestroyed = 0
        gameTime = 0

        // Reset base parameters
        baseEnemySpawnInterval = 2.0
        baseEnemyShotInterval = 1.5
        baseEnemySpeed = 1.5
        baseEnemyHealth = 40
    }

    // MARK: - Difficulty Information
    func getDifficultyDescription() -> String {
        switch currentLevel {
        case 1...3:
            return "Easy"
        case 4...6:
            return "Medium"
        case 7...10:
            return "Hard"
        case 11...15:
            return "Very Hard"
        default:
            return "Insane"
        }
    }

    func getNextLevelThreshold() -> Int {
        return currentLevel * scorePerLevel
    }

    func getProgressToNextLevel() -> Float {
        let currentLevelThreshold = (currentLevel - 1) * scorePerLevel
        let nextLevelThreshold = currentLevel * scorePerLevel
        let progress = score - currentLevelThreshold
        let totalNeeded = nextLevelThreshold - currentLevelThreshold

        guard totalNeeded > 0 else { return 1.0 }
        return Float(progress) / Float(totalNeeded)
    }
}

// MARK: - Extensions
extension DifficultyManager {

    // MARK: - Wave Management
    func shouldStartNewWave() -> Bool {
        // Logic for determining when to start new enemy waves
        return enemiesDestroyed % (currentLevel * 3) == 0
    }

    func getWaveSize() -> Int {
        // Number of enemies in a wave
        return min(8, currentLevel + 2)
    }

    func getWaveDelay() -> TimeInterval {
        // Delay between waves
        return max(1.0, 5.0 - Double(currentLevel) * 0.2)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let difficultyLevelUp = Notification.Name("difficultyLevelUp")
    static let newWaveStarting = Notification.Name("newWaveStarting")
}

// CGPoint extension is already defined in PhysicsConstants.swift