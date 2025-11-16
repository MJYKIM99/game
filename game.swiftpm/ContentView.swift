import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @State private var showGame = false

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            if showGame {
                // Game View
                GameView()
                    .environmentObject(gameManager)
                    .onTapGesture { location in
                        // Convert touch location to game coordinates
                        // This would need proper coordinate transformation
                        gameManager.playerShoot(at: location)
                    }
            } else {
                // Main Menu
                MainMenuView(onStartGame: {
                    showGame = true
                })
                .environmentObject(gameManager)
            }
        }
    }
}

// MARK: - Main Menu View
struct MainMenuView: View {
    @EnvironmentObject var gameManager: GameManager
    let onStartGame: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            // Title
            VStack(spacing: 10) {
                Text("SPACE")
                    .font(.custom("Courier", size: 48))
                    .foregroundColor(.white)
                    .shadow(color: .gray, radius: 3)

                Text("BATTLES")
                    .font(.custom("Courier", size: 36))
                    .foregroundColor(.white)
                    .shadow(color: .gray, radius: 3)

                Text("像素战争")
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.gray)
            }
            .padding(.top, 80)

            Spacer()

            // Menu Options
            VStack(spacing: 20) {
                // Start Game Button
                Button(action: {
                    onStartGame()
                    gameManager.startGame()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("START GAME")
                    }
                    .font(.custom("Courier", size: 24))
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())

                // High Score
                VStack(spacing: 5) {
                    Text("HIGH SCORE")
                        .font(.custom("Courier", size: 16))
                        .foregroundColor(.gray)

                    Text("\(gameManager.highScore)")
                        .font(.custom("Courier", size: 32))
                        .foregroundColor(.white)
                        .shadow(color: .gray, radius: 2)
                }
            }

            Spacer()

            // Instructions
            VStack(spacing: 10) {
                Text("CONTROLS")
                    .font(.custom("Courier", size: 18))
                    .foregroundColor(.white)

                VStack(spacing: 5) {
                    Text("🎮 Virtual Joystick: Move spaceship")
                        .font(.custom("Courier", size: 14))
                        .foregroundColor(.gray)

                    Text("👆 Tap: Shoot projectiles")
                        .font(.custom("Courier", size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 40)

            // Game Mode Indicator
            Text("黑白像素风格射击游戏")
                .font(.custom("Courier", size: 12))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameManager())
}
