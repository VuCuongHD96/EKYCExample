//
//  EKYCContainerView.swift
//  EKYCExample
//
//  Created by sun on 26/8/26.
//

import SwiftUI

public struct EKYCContainerView: View {
    public var onComplete: (() -> Void)?
    @StateObject private var viewModel = EKYCFlowViewModel()
    @Environment(\.dismiss) private var dismiss

    public init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()

                switch viewModel.currentStep {
                case .welcome:
                    EKYCWelcomeView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .leading)))

                case .scanFront:
                    // Placeholder cho bước quét giấy tờ tiếp theo
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.12))
                                .frame(width: 90, height: 90)

                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 44))
                                .foregroundColor(.blue)
                        }

                        Text("Quét \(viewModel.documentType.rawValue)")
                            .font(.system(size: 22, weight: .bold))

                        Text("Bước quét giấy tờ tuỳ thân đang được hoàn thiện ở nhánh tính năng tiếp theo.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.backToWelcome()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left")
                                Text("Quay lại màn hình chuẩn bị")
                            }
                            .font(.system(size: 15, weight: .semibold))
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 12)
                    }
                    .padding()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))

                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            .navigationTitle(viewModel.currentStep == .welcome ? "Chuẩn bị eKYC" : viewModel.currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStep != .welcome {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.backToWelcome()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    EKYCContainerView()
}
