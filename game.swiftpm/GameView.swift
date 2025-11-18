import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject private var gameManager = GameManager()

    var body: some View {
        ZStack {
            // SpriteKit 游戏场景
            SpriteView(scene: gameManager.gameScene)
                .ignoresSafeArea()
                .onAppear {
                    gameManager.startGame()
                }

            // UI 覆盖层
            VStack {
                HStack {
                    Text("Score: \(gameManager.score)")
                        .font(.custom("Courier", size: 20))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2)

                    Spacer()

                    Text("Health: \(gameManager.playerHealth)")
                        .font(.custom("Courier", size: 20))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2)
                }
                .padding()

                Spacer()

                // 虚拟摇杆
                VirtualJoystick { joystickData in
                    gameManager.handleJoystickInput(joystickData)
                }
                .frame(width: 120, height: 120)
                .padding(.leading, 30)
                .padding(.bottom, 30)
                .allowsHitTesting(true)
            }

            // 游戏结束界面
            if gameManager.isGameOver {
                VStack {
                    Text("GAME OVER")
                        .font(.custom("Courier", size: 40))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 3)

                    Text("Final Score: \(gameManager.score)")
                        .font(.custom("Courier", size: 24))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2)

                    Button("Restart") {
                        gameManager.restartGame()
                    }
                    .font(.custom("Courier", size: 20))
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.7))
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    // 处理触摸射击 - 使用拖动结束的位置
                    print("[DEBUG] GameView DragGesture.onEnded at: \(value.location)")
                    gameManager.playerShoot(at: value.location)
                }
        )
    }
}

#Preview {
    GameView()
}