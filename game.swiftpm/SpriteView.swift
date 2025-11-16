import SwiftUI
import SpriteKit

struct SpriteView: UIViewRepresentable {
    let scene: SKScene

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()

        // 设置场景尺寸
        if scene.size.equalTo(.zero) {
            scene.size = UIScreen.main.bounds.size
        }

        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false

        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        // Update if needed
    }
}