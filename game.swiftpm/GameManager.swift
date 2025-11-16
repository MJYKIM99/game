import Foundation
import SwiftUI
import SpriteKit

@MainActor
class GameManager: ObservableObject {

    // MARK: - Game Properties
    @Published var score: Int = 0
    @Published var playerHealth: Int = 100
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    @Published var currentLevel: Int = 1
    @Published var highScore: Int = 0

    // Game Scene
    let gameScene: GameScene

    // Game State
    private var gameStartTime: TimeInterval = 0
    private var isGameRunning: Bool = false

    // Managers
    private let difficultyManager = DifficultyManager()

    // MARK: - Initialization
    init() {
        gameScene = GameScene()
        setupGame()
        loadHighScore()
    }

    private func setupGame() {
        gameScene.gameManager = self
        setupNotificationObservers()
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(difficultyLevelUp),
            name: .difficultyLevelUp,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Game Control
    func startGame() {
        guard !isGameRunning else { return }

        resetGame()
        gameStartTime = Date().timeIntervalSince1970
        isGameRunning = true
        isGameOver = false
        isPaused = false

        gameScene.startGame()

        print("Game Started!")
    }

    func pauseGame() {
        guard isGameRunning && !isGameOver else { return }
        isPaused = true
        gameScene.isPaused = true

        print("Game Paused")
    }

    func resumeGame() {
        guard isGameRunning && isPaused else { return }
        isPaused = false
        gameScene.isPaused = false

        print("Game Resumed")
    }

    func restartGame() {
        startGame()
    }

    func gameOver() {
        guard isGameRunning else { return }

        isGameRunning = false
        isGameOver = true
        gameScene.stopGame()

        // Calculate final score with bonuses
        let survivalBonus = difficultyManager.calculateSurvivalBonus()
        let finalScore = score + survivalBonus
        updateScore(finalScore)

        // Update high score
        if finalScore > highScore {
            highScore = finalScore
            saveHighScore()
        }

        print("Game Over! Final Score: \(finalScore), High Score: \(highScore)")
    }

    private func resetGame() {
        score = 0
        playerHealth = 100
        currentLevel = 1
        isGameOver = false
        isPaused = false

        difficultyManager.resetDifficulty()
        gameScene.resetGame()

        print("Game Reset")
    }

    // MARK: - Game Events
    func enemyDestroyed() {
        let points = 10
        updateScore(score + points)

        // Update difficulty based on progress
        updateDifficulty()

        print("Enemy Destroyed! Score: \(score)")
    }

    func playerHealthUpdated(_ newHealth: Int) {
        playerHealth = newHealth

        if playerHealth <= 0 && !isGameOver {
            gameOver()
        }

        print("Player Health: \(playerHealth)")
    }

    func handleJoystickInput(_ joystickData: JoystickData) {
        guard isGameRunning && !isPaused && !isGameOver else { return }

        gameScene.setJoystickDirection(joystickData.direction)
    }

    func playerShoot(at targetPoint: CGPoint) {
        guard isGameRunning && !isPaused && !isGameOver else { return }

        gameScene.playerShoot(at: targetPoint)
    }

    // MARK: - Score Management
    private func updateScore(_ newScore: Int) {
        score = newScore
        difficultyManager.score = newScore
    }

    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "HighScore")
    }

    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "HighScore")
    }

    // MARK: - Difficulty Management
    private func updateDifficulty() {
        let gameTime = Date().timeIntervalSince1970 - gameStartTime
        let enemiesDestroyed = difficultyManager.enemiesDestroyed + 1

        difficultyManager.updateDifficulty(
            score: score,
            timePlayed: gameTime,
            enemiesDestroyed: enemiesDestroyed
        )

        if difficultyManager.currentLevel != currentLevel {
            currentLevel = difficultyManager.currentLevel
        }
    }

    @objc private func difficultyLevelUp(_ notification: Notification) {
        guard let newLevel = notification.userInfo?["newLevel"] as? Int else { return }

        currentLevel = newLevel

        // Show level up effect (could add visual/audio feedback)
        print("Level Up to \(newLevel)!")
    }

    // MARK: - Game Statistics
    func getGameStatistics() -> GameStatistics {
        let gameTime = isGameRunning ? Date().timeIntervalSince1970 - gameStartTime : 0

        return GameStatistics(
            score: score,
            highScore: highScore,
            currentLevel: currentLevel,
            enemiesDestroyed: difficultyManager.enemiesDestroyed,
            gameTime: gameTime,
            accuracy: calculateAccuracy()
        )
    }

    private func calculateAccuracy() -> Float {
        // This would need to track shots fired vs hits
        // For now, return a placeholder
        return 0.75
    }

    // MARK: - Game Configuration
    func getGameSettings() -> GameSettings {
        return GameSettings(
            soundEnabled: true,
            musicEnabled: true,
            vibrationEnabled: true,
            difficultyMode: .normal
        )
    }
}

// MARK: - Data Structures
struct GameStatistics {
    let score: Int
    let highScore: Int
    let currentLevel: Int
    let enemiesDestroyed: Int
    let gameTime: TimeInterval
    let accuracy: Float

    var formattedGameTime: String {
        let minutes = Int(gameTime) / 60
        let seconds = Int(gameTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct GameSettings {
    let soundEnabled: Bool
    let musicEnabled: Bool
    let vibrationEnabled: Bool
    let difficultyMode: DifficultyMode
}

enum DifficultyMode {
    case easy
    case normal
    case hard
    case insane

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        case .insane: return "Insane"
        }
    }

    var difficultyMultiplier: Float {
        switch self {
        case .easy: return 0.7
        case .normal: return 1.0
        case .hard: return 1.5
        case .insane: return 2.0
        }
    }
}

// MARK: - Game Manager Extensions
extension GameManager {

    // MARK: - Save/Load Game State
    func saveGameState() {
        let gameState = GameState(
            score: score,
            playerHealth: playerHealth,
            currentLevel: currentLevel,
            gameTime: Date().timeIntervalSince1970 - gameStartTime,
            enemiesDestroyed: difficultyManager.enemiesDestroyed
        )

        if let encoded = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(encoded, forKey: "GameState")
        }
    }

    func loadGameState() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: "GameState"),
              let gameState = try? JSONDecoder().decode(GameState.self, from: data) else {
            return false
        }

        score = gameState.score
        playerHealth = gameState.playerHealth
        currentLevel = gameState.currentLevel
        difficultyManager.enemiesDestroyed = gameState.enemiesDestroyed

        // Resume game from saved state
        gameStartTime = Date().timeIntervalSince1970 - gameState.gameTime
        isGameRunning = true
        isPaused = false
        isGameOver = false

        gameScene.startGame()

        return true
    }

    func clearSavedGame() {
        UserDefaults.standard.removeObject(forKey: "GameState")
    }
}

// MARK: - Game State Data Structure
struct GameState: Codable {
    let score: Int
    let playerHealth: Int
    let currentLevel: Int
    let gameTime: TimeInterval
    let enemiesDestroyed: Int
}

// MARK: - Preview Support
#Preview {
    GameView()
        .environmentObject(GameManager())
}