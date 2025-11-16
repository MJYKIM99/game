import SwiftUI
import CoreGraphics

struct JoystickData {
    let direction: CGPoint
    let magnitude: CGFloat
    let isActive: Bool

    init(direction: CGPoint = .zero, magnitude: CGFloat = 0, isActive: Bool = false) {
        self.direction = direction
        self.magnitude = magnitude
        self.isActive = isActive
    }
}

struct VirtualJoystick: View {

    // MARK: - Properties
    @State private var joystickPosition: CGPoint = .zero
    @State private var isDragging: Bool = false
    @State private var currentDirection: CGPoint = .zero

    private let joystickRadius: CGFloat = 40
    private let knobRadius: CGFloat = 15
    private let maxDistance: CGFloat

    private let onJoystickMove: (JoystickData) -> Void

    // MARK: - Initialization
    init(onJoystickMove: @escaping (JoystickData) -> Void) {
        self.onJoystickMove = onJoystickMove
        self.maxDistance = joystickRadius - knobRadius
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景圆圈
                Circle()
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 3)
                    .frame(width: joystickRadius * 2, height: joystickRadius * 2)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                    )

                // 十字方向指示器
               十字方向指示器

                // 摇杆按钮
                Circle()
                    .fill(isDragging ? Color.white : Color.white.opacity(0.8))
                    .frame(width: knobRadius * 2, height: knobRadius * 2)
                    .shadow(color: .black, radius: 3)
                    .position(
                        x: joystickRadius + joystickPosition.x,
                        y: joystickRadius + joystickPosition.y
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDragChanged(value: value, in: geometry.size)
                            }
                            .onEnded { value in
                                handleDragEnded()
                            }
                    )
            }
        }
        .frame(width: joystickRadius * 2, height: joystickRadius * 2)
        .onChange(of: currentDirection) { newDirection in
            let joystickData = JoystickData(
                direction: newDirection,
                magnitude: sqrt(newDirection.x * newDirection.x + newDirection.y * newDirection.y),
                isActive: isDragging
            )
            onJoystickMove(joystickData)
        }
    }

    // MARK: - Views
    private var 十字方向指示器: some View {
        ZStack {
            // 垂直线
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 2, height: joystickRadius * 2)

            // 水平线
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: joystickRadius * 2, height: 2)

            // 方向点
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 6, height: 6)
                .position(x: joystickRadius, y: 10) // 上

            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 6, height: 6)
                .position(x: joystickRadius * 2 - 10, y: joystickRadius) // 右

            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 6, height: 6)
                .position(x: joystickRadius, y: joystickRadius * 2 - 10) // 下

            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 6, height: 6)
                .position(x: 10, y: joystickRadius) // 左
        }
    }

    // MARK: - Gesture Handling
    private func handleDragChanged(value: DragGesture.Value, in size: CGSize) {
        let center = CGPoint(x: joystickRadius, y: joystickRadius)
        let currentPosition = value.location

        // 计算相对于中心的位置
        let relativePosition = CGPoint(
            x: currentPosition.x - center.x,
            y: currentPosition.y - center.y
        )

        // 计算距离
        let distance = sqrt(relativePosition.x * relativePosition.x + relativePosition.y * relativePosition.y)

        // 限制在最大距离内
        let clampedPosition: CGPoint
        if distance <= maxDistance {
            clampedPosition = relativePosition
        } else {
            let normalizedPosition = relativePosition.normalized()
            clampedPosition = CGPoint(
                x: normalizedPosition.x * maxDistance,
                y: normalizedPosition.y * maxDistance
            )
        }

        withAnimation(.easeOut(duration: 0.1)) {
            joystickPosition = clampedPosition
            isDragging = true
            currentDirection = clampedPosition.normalized()
        }
    }

    private func handleDragEnded() {
        withAnimation(.easeOut(duration: 0.2)) {
            joystickPosition = .zero
            isDragging = false
            currentDirection = .zero
        }
    }
}

// CGPoint extension is already defined in PhysicsConstants.swift

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            Spacer()

            VirtualJoystick { joystickData in
                print("Direction: \(joystickData.direction), Magnitude: \(joystickData.magnitude), Active: \(joystickData.isActive)")
            }
            .frame(width: 120, height: 120)
            .padding()

            Spacer()
        }
    }
}