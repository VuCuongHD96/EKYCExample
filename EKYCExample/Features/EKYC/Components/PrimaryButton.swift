//
//  PrimaryButton.swift
//  EKYCExample
//

import SwiftUI

public struct PrimaryButton: View {
    public let title: String
    public let iconName: String?
    public let isLoading: Bool
    public let isEnabled: Bool
    public let action: () -> Void

    public init(
        title: String,
        iconName: String? = nil,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: {
            guard isEnabled && !isLoading else { return }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    if let iconName = iconName {
                        Image(systemName: iconName)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: isEnabled ? [Color.blue, Color.cyan] : [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
            .shadow(color: isEnabled ? Color.blue.opacity(0.3) : Color.clear, radius: 8, y: 4)
        }
        .disabled(!isEnabled || isLoading)
    }
}
