//
//  EKYCDocumentScanView.swift
//  EKYCExample
//

import SwiftUI

public struct EKYCDocumentScanView: View {
    @ObservedObject var viewModel: EKYCFlowViewModel

    public init(viewModel: EKYCFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Live Camera Feed
            CameraPreviewView(cameraService: viewModel.cameraService)
                .ignoresSafeArea()

            // Card Frame & Scan Guide Overlay
            DocumentOverlayView(
                isCardAligned: viewModel.isCardAligned,
                instruction: viewModel.documentInstruction,
                isTorchOn: viewModel.cameraService.isTorchOn,
                onTorchTap: {
                    viewModel.cameraService.toggleTorch()
                },
                onCaptureTap: {
                    Task {
                        await viewModel.captureDocument()
                    }
                }
            )
        }
    }
}

#Preview {
    EKYCDocumentScanView(viewModel: EKYCFlowViewModel())
}

