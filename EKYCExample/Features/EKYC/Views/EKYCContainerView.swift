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

                case .scanFront, .scanBack:
                    // Màn hình quét giấy tờ với Camera Preview & khung căn chỉnh
                    EKYCDocumentScanView(viewModel: viewModel)
                        .transition(.opacity)

                case .reviewFront, .reviewBack:
                    // Màn hình xem lại ảnh đã chụp
                    let image = (viewModel.currentStep == .reviewFront) ? viewModel.capturedDocs.frontImage : viewModel.capturedDocs.backImage
                    VStack(spacing: 20) {
                        Text(viewModel.currentStep == .reviewFront ? "Kiểm tra ảnh mặt trước" : "Kiểm tra ảnh mặt sau")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.top, 20)

                        if let uiImage = image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 240)
                                .cornerRadius(12)
                                .shadow(radius: 8)
                                .padding(.horizontal, 20)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .overlay(Text("Không có ảnh").foregroundColor(.secondary))
                                .padding(.horizontal, 20)
                        }

                        Text("Đảm bảo thông tin trên giấy tờ rõ nét, không bị loá sáng hay mất góc.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                        Spacer()

                        HStack(spacing: 16) {
                            Button(action: {
                                let step: EKYCStep = (viewModel.currentStep == .reviewFront) ? .scanFront : .scanBack
                                viewModel.startDocumentScan(step: step)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Chụp lại")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(UIColor.secondarySystemBackground))
                                .foregroundColor(.primary)
                                .cornerRadius(14)
                            }

                            Button(action: {
                                if viewModel.currentStep == .reviewFront && viewModel.documentType.hasBackSide {
                                    viewModel.startDocumentScan(step: .scanBack)
                                } else {
                                    onComplete?()
                                    dismiss()
                                }
                            }) {
                                HStack {
                                    Text(viewModel.currentStep == .reviewFront && viewModel.documentType.hasBackSide ? "Mặt sau" : "Hoàn thành")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))

                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStep != .welcome {
                        Button(action: handleBackAction) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(isCameraScanning ? .white : .primary)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.cameraService.stopSession()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(isCameraScanning ? .white.opacity(0.8) : .secondary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.startFlow()
        }
        .onDisappear {
            viewModel.cameraService.stopSession()
        }
    }

    private var isCameraScanning: Bool {
        viewModel.currentStep == .scanFront || viewModel.currentStep == .scanBack
    }

    private var navTitle: String {
        switch viewModel.currentStep {
        case .welcome:
            return "Chuẩn bị eKYC"
        case .scanFront:
            return "Quét mặt trước \(viewModel.documentType.rawValue)"
        case .scanBack:
            return "Quét mặt sau \(viewModel.documentType.rawValue)"
        case .reviewFront:
            return "Xác nhận mặt trước"
        case .reviewBack:
            return "Xác nhận mặt sau"
        default:
            return viewModel.currentStep.title
        }
    }

    private func handleBackAction() {
        switch viewModel.currentStep {
        case .welcome:
            dismiss()
        case .scanFront:
            viewModel.backToWelcome()
        case .reviewFront:
            viewModel.startDocumentScan(step: .scanFront)
        case .scanBack:
            viewModel.currentStep = .reviewFront
        case .reviewBack:
            viewModel.startDocumentScan(step: .scanBack)
        default:
            viewModel.backToWelcome()
        }
    }
}

#Preview {
    EKYCContainerView()
}
