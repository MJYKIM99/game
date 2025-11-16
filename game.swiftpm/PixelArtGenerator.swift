import SpriteKit
import UIKit

class PixelArtGenerator {

    // MARK: - Pixel Art Constants
    static let pixelSize: CGFloat = 2
    static let baseColorPalette: [SKColor] = [
        .black,      // 0: 背景色
        .white,      // 1: 主色
        .gray,       // 2: 灰色
        .darkGray,   // 3: 深灰
        .lightGray,  // 4: 浅灰
        .clear       // 5: 透明
    ]

    // MARK: - Texture Generation
    static func createPixelTexture(width: Int, height: Int, pattern: [[Int]]) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(width) * pixelSize, height: CGFloat(height) * pixelSize))

        let image = renderer.image { context in
            let cgContext = context.cgContext

            for (y, row) in pattern.enumerated() {
                for (x, colorIndex) in row.enumerated() {
                    if colorIndex >= 0 && colorIndex < baseColorPalette.count {
                        let color = baseColorPalette[colorIndex]
                        cgContext.setFillColor(color.cgColor)
                        cgContext.fill(CGRect(
                            x: CGFloat(x) * pixelSize,
                            y: CGFloat(height - y - 1) * pixelSize, // Flip Y axis
                            width: pixelSize,
                            height: pixelSize
                        ))
                    }
                }
            }
        }

        return SKTexture(image: image)
    }

    // MARK: - Predefined Patterns
    static func createPlayerShipPattern() -> [[Int]] {
        return [
            [0, 0, 2, 1, 1, 2, 0, 0],    // 机翼上部
            [0, 2, 1, 1, 1, 1, 2, 0],    // 机翼中上
            [2, 1, 1, 1, 1, 1, 1, 2],    // 机翼中部
            [1, 1, 1, 1, 1, 1, 1, 1],    // 机身主体
            [0, 1, 1, 3, 3, 1, 1, 0],    // 座舱
            [0, 0, 2, 2, 2, 2, 0, 0],    // 引擎上部
            [0, 2, 4, 4, 4, 4, 2, 0],    // 引擎发光
            [2, 4, 1, 1, 1, 1, 4, 2]     // 引擎底部
        ]
    }

    static func createEnemyShipPattern() -> [[Int]] {
        return [
            [0, 0, 3, 1, 1, 3, 0, 0],
            [0, 3, 1, 0, 0, 1, 3, 0],
            [3, 1, 0, 2, 2, 0, 1, 3],
            [1, 0, 2, 2, 2, 2, 0, 1],
            [1, 0, 2, 1, 1, 2, 0, 1],
            [3, 1, 0, 2, 2, 0, 1, 3],
            [0, 3, 1, 0, 0, 1, 3, 0],
            [0, 0, 3, 1, 1, 3, 0, 0]
        ]
    }

    static func createPlayerProjectilePattern() -> [[Int]] {
        return [
            [0, 0, 2, 2, 0, 0],
            [0, 2, 1, 1, 2, 0],
            [2, 1, 1, 1, 1, 2],
            [0, 2, 1, 1, 2, 0],
            [0, 0, 2, 2, 0, 0]
        ]
    }

    static func createEnemyProjectilePattern() -> [[Int]] {
        return [
            [0, 0, 3, 3, 0, 0],
            [0, 3, 1, 1, 3, 0],
            [3, 1, 3, 3, 1, 3],
            [0, 3, 1, 1, 3, 0],
            [0, 0, 3, 3, 0, 0]
        ]
    }

    // MARK: - Animated Patterns
    static func createExplosionPattern(frame: Int) -> [[Int]] {
        switch frame {
        case 0:
            return [
                [0, 0, 0, 3, 0, 0, 0],
                [0, 0, 3, 1, 3, 0, 0],
                [0, 3, 1, 1, 1, 3, 0],
                [3, 1, 1, 1, 1, 1, 3],
                [0, 3, 1, 1, 1, 3, 0],
                [0, 0, 3, 1, 3, 0, 0],
                [0, 0, 0, 3, 0, 0, 0]
            ]
        case 1:
            return [
                [0, 3, 1, 1, 1, 3, 0],
                [3, 1, 1, 3, 1, 1, 3],
                [1, 1, 3, 1, 3, 1, 1],
                [1, 3, 1, 3, 1, 3, 1],
                [1, 1, 3, 1, 3, 1, 1],
                [3, 1, 1, 3, 1, 1, 3],
                [0, 3, 1, 1, 1, 3, 0]
            ]
        default:
            return [
                [3, 1, 1, 1, 1, 1, 3],
                [1, 1, 1, 1, 1, 1, 1],
                [1, 1, 3, 1, 3, 1, 1],
                [1, 1, 1, 1, 1, 1, 1],
                [1, 1, 3, 1, 3, 1, 1],
                [1, 1, 1, 1, 1, 1, 1],
                [3, 1, 1, 1, 1, 1, 3]
            ]
        }
    }

    // MARK: - Visual Effects
    static func createScanlineEffect() -> SKSpriteNode {
        let pattern: [[Int]] = [
            [1, 0, 1, 0, 1, 0, 1, 0],
            [0, 1, 0, 1, 0, 1, 0, 1],
            [1, 0, 1, 0, 1, 0, 1, 0],
            [0, 1, 0, 1, 0, 1, 0, 1]
        ]

        let texture = createPixelTexture(width: 8, height: 4, pattern: pattern)
        let node = SKSpriteNode(texture: texture)

        node.alpha = 0.1
        node.blendMode = .multiply

        // Animate the scanline effect
        let moveAction = SKAction.moveBy(x: 0, y: -4, duration: 0.5)
        let resetAction = SKAction.moveBy(x: 0, y: 4, duration: 0)
        let sequenceAction = SKAction.sequence([moveAction, resetAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)

        node.run(repeatAction)

        return node
    }

    static func createNoiseEffect() -> SKSpriteNode {
        let width = 100
        let height = 100
        var pattern: [[Int]] = []

        for _ in 0..<height {
            var row: [Int] = []
            for _ in 0..<width {
                let noise = Int.random(in: 0...4)
                row.append(noise == 0 ? 5 : noise - 1) // Mostly transparent with some noise
            }
            pattern.append(row)
        }

        let texture = createPixelTexture(width: width, height: height, pattern: pattern)
        let node = SKSpriteNode(texture: texture)

        node.alpha = 0.05
        node.blendMode = .screen

        return node
    }

    // MARK: - UI Elements
    static func createPixelButton(text: String, size: CGSize) -> SKNode {
        let container = SKNode()

        // Button background pattern
        let buttonPattern: [[Int]] = [
            [1, 1, 1, 1, 1, 1, 1, 1],
            [1, 3, 3, 3, 3, 3, 3, 1],
            [1, 3, 0, 0, 0, 0, 3, 1],
            [1, 3, 0, 0, 0, 0, 3, 1],
            [1, 3, 0, 0, 0, 0, 3, 1],
            [1, 3, 3, 3, 3, 3, 3, 1],
            [1, 1, 1, 1, 1, 1, 1, 1]
        ]

        let backgroundTexture = createPixelTexture(width: 8, height: 7, pattern: buttonPattern)
        let background = SKSpriteNode(texture: backgroundTexture, size: size)
        background.color = .white
        background.blendMode = .replace

        // Create text label (using SKLabelNode for simplicity)
        let label = SKLabelNode(fontNamed: "Courier")
        label.text = text
        label.fontSize = size.height * 0.4
        label.fontColor = .black
        label.position = CGPoint(x: 0, y: -size.height * 0.1)

        container.addChild(background)
        container.addChild(label)

        return container
    }

    static func createPixelHealthBar(health: Float, maxSize: CGSize) -> SKNode {
        let container = SKNode()

        // Background bar
        let backgroundPattern: [[Int]] = [
            [3, 3, 3, 3, 3, 3, 3, 3],
            [3, 5, 5, 5, 5, 5, 5, 3],
            [3, 5, 5, 5, 5, 5, 5, 3],
            [3, 3, 3, 3, 3, 3, 3, 3]
        ]

        let backgroundTexture = createPixelTexture(width: 8, height: 4, pattern: backgroundPattern)
        let background = SKSpriteNode(texture: backgroundTexture, size: maxSize)
        background.color = .darkGray
        background.blendMode = .replace

        // Health bar
        let healthWidth = maxSize.width * CGFloat(health)
        let healthPattern: [[Int]] = [
            [1, 1, 1, 1, 1, 1, 1, 1],
            [1, 2, 2, 2, 2, 2, 2, 1],
            [1, 2, 2, 2, 2, 2, 2, 1],
            [1, 1, 1, 1, 1, 1, 1, 1]
        ]

        let healthTexture = createPixelTexture(width: 8, height: 4, pattern: healthPattern)
        let healthBar = SKSpriteNode(texture: healthTexture, size: CGSize(width: healthWidth, height: maxSize.height))
        healthBar.color = health > 0.3 ? .white : .red
        healthBar.blendMode = .replace
        healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBar.position = CGPoint(x: -maxSize.width/2, y: 0)

        container.addChild(background)
        container.addChild(healthBar)

        return container
    }

    // MARK: - Particle Effects
    static func createPixelParticle(color: SKColor, size: CGFloat) -> SKSpriteNode {
        let pattern: [[Int]] = [[1]]
        let texture = createPixelTexture(width: 1, height: 1, pattern: pattern)
        let particle = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
        particle.color = color
        particle.blendMode = .add
        return particle
    }

    // MARK: - Background Generation
    static func createStarfieldBackground(size: CGSize, starCount: Int) -> SKNode {
        let container = SKNode()

        for _ in 0..<starCount {
            let star = createPixelParticle(color: .white, size: CGFloat.random(in: 1...3))
            star.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )

            // Add twinkling animation
            let fadeAction = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 1...3)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 1...3))
            ])
            star.run(SKAction.repeatForever(fadeAction))

            container.addChild(star)
        }

        return container
    }
}

// MARK: - Visual Effects Manager
class VisualEffectsManager {

    static func applyRetroEffects(to node: SKNode) {
        // Add scanline effect
        let scanlines = PixelArtGenerator.createScanlineEffect()
        scanlines.position = .zero
        scanlines.zPosition = 1000
        node.addChild(scanlines)

        // Add noise effect
        let noise = PixelArtGenerator.createNoiseEffect()
        noise.position = .zero
        noise.zPosition = 999
        node.addChild(noise)
    }

    static func createDamageFlash(duration: TimeInterval) -> SKAction {
        let colorize = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: duration * 0.2)
        let uncolorize = SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: duration * 0.8)
        return SKAction.sequence([colorize, uncolorize])
    }

    static func createPickupGlow() -> SKAction {
        let glowUp = SKAction.colorize(with: .yellow, colorBlendFactor: 0.8, duration: 0.5)
        let glowDown = SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: 0.5)
        return SKAction.repeatForever(SKAction.sequence([glowUp, glowDown]))
    }
}