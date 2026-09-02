//
//  DocumentOverlayView.swift
//  EKYCExample
//

import SwiftUI

public struct DocumentOverlayView: View {
    public let isCardAligned: Bool
    public let instruction: String
    public let onCaptureTap: () -> Void
    public let onTorchTap: () -> Void
    public let isTorchOn: Bool

    @State private var laserOffset: CGFloat = -120

    public init(
        isCardAligned: Bool,
        instruction: String,
        isTorchOn: Bool = false,
        onTorchTap: @escaping () -> Void = {},
        onCaptureTap: @escaping () -> Void
    ) {
        self.isCardAligned = isCardAligned
        self.instruction = instruction
        self.isTorchOn = isTorchOn
        self.onTorchTap = onTorchTap
        self.onCaptureTap = onCaptureTap
    }

    public var body: some View {
        GeometryReader { geometry in
            let frameWidth = min(geometry.size.width - 40, 360)
            let frameHeight = frameWidth / 1.586 // Standard ID-1 ratio

            ZStack {
                // Dimmed background with transparent card cut-out
                Color.black.opacity(0.65)
                    .mask(
                        CutoutMaskShape(
                            cutoutRect: CGRect(
                                x: (geometry.size.width - frameWidth) / 2,
                                y: (geometry.size.height - frameHeight) / 2 - 40,
                                width: frameWidth,
                                height: frameHeight
                            ),
                            cornerRadius: 16
                        )
                        .fill(style: FillStyle(eoFill: true))
                    )
                    .ignoresSafeArea()

                // Card Frame Borders and Corners
                VStack {
                    Spacer()
                        .frame(height: (geometry.size.height - frameHeight) / 2 - 40)

                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isCardAligned ? Color.green : Color.white.opacity(0.4),
                                lineWidth: isCardAligned ? 2.5 : 1.5
                            )
                            .frame(width: frameWidth, height: frameHeight)
                            .shadow(color: isCardAligned ? Color.green.opacity(0.6) : Color.clear, radius: 10)

                        // 4 Corner Brackets
                        CornerBracketsView(width: frameWidth, height: frameHeight, isHighlighted: isCardAligned)

                        // Laser Scan Line Animation
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        isCardAligned ? Color.green.opacity(0.8) : Color.cyan.opacity(0.8),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: frameWidth - 10, height: 3)
                            .offset(y: laserOffset)
                            .clipped()
                    }
                    .frame(width: frameWidth, height: frameHeight)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.8)
                            .repeatForever(autoreverses: true)
                        ) {
                            laserOffset = frameHeight / 2 - 15
                        }
                    }

                    Spacer()
                }

                // Top & Bottom Controls & Guidance
                VStack(spacing: 20) {
                    // Top Bar
                    HStack {
                        Spacer()
                        Button(action: onTorchTap) {
                            Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(isTorchOn ? .yellow : .white)
                                .padding(12)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                    Spacer()

                    // Instruction Pill
                    HStack(spacing: 8) {
                        Image(systemName: isCardAligned ? "checkmark.circle.fill" : "viewfinder")
                            .foregroundColor(isCardAligned ? .green : .cyan)
                        Text(instruction)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.75))
                            .overlay(
                                Capsule()
                                    .stroke(isCardAligned ? Color.green.opacity(0.6) : Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)

                    // Manual Shutter Button
                    Button(action: onCaptureTap) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 72, height: 72)
                            Circle()
                                .fill(isCardAligned ? Color.green : Color.white)
                                .frame(width: 58, height: 58)
                        }
                    }
                    .padding(.bottom, 36)
                }
            }
        }
    }
}

// MARK: - Cutout Mask Shape
private struct CutoutMaskShape: Shape {
    let cutoutRect: CGRect
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        let roundedCutout = UIBezierPath(roundedRect: cutoutRect, cornerRadius: cornerRadius)
        path.addPath(Path(roundedCutout.cgPath))
        return path
    }
}

// MARK: - Corner Brackets
private struct CornerBracketsView: View {
    let width: CGFloat
    let height: CGFloat
    let isHighlighted: Bool

    private let bracketLength: CGFloat = 24
    private let strokeWidth: CGFloat = 3.5

    var body: some View {
        let color = isHighlighted ? Color.green : Color.cyan
        ZStack {
            // Top Left
            Path { p in
                p.move(to: CGPoint(x: 0, y: bracketLength))
                p.addLine(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: bracketLength, y: 0))
            }
            .stroke(color, lineWidth: strokeWidth)
            .offset(x: -width / 2 + 10, y: -height / 2 + 10)

            // Top Right
            Path { p in
                p.move(to: CGPoint(x: -bracketLength, y: 0))
                p.addLine(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: 0, y: bracketLength))
            }
            .stroke(color, lineWidth: strokeWidth)
            .offset(x: width / 2 - 10, y: -height / 2 + 10)

            // Bottom Left
            Path { p in
                p.move(to: CGPoint(x: 0, y: -bracketLength))
                p.addLine(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: bracketLength, y: 0))
            }
            .stroke(color, lineWidth: strokeWidth)
            .offset(x: -width / 2 + 10, y: height / 2 - 10)

            // Bottom Right
            Path { p in
                p.move(to: CGPoint(x: -bracketLength, y: 0))
                p.addLine(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: 0, y: -bracketLength))
            }
            .stroke(color, lineWidth: strokeWidth)
            .offset(x: width / 2 - 10, y: height / 2 - 10)
        }
    }
}
