//
//  EKYCFlowViewModel.swift
//  EKYCExample
//

import SwiftUI
import Combine
import AVFoundation
import Vision

@MainActor
public final class EKYCFlowViewModel: ObservableObject, CameraServiceDelegate {
    // MARK: - Flow State
    @Published public var currentStep: EKYCStep = .welcome
    @Published public var documentType: DocumentType = .chipID
    @Published public var capturedDocs: CapturedDocument = CapturedDocument()

    // MARK: - Camera & Permissions
    @Published public var isCameraPermissionGranted: Bool = false
    public let cameraService = CameraService()
    public let permissionManager = CameraPermissionManager.shared

    // MARK: - Document Scanning State
    @Published public var isCardAligned: Bool = false
    @Published public var documentInstruction: String = "Đặt giấy tờ vào trong khung hình"
    @Published public var errorMessage: String?

    // MARK: - Private Services & Feedback
    private let docDetectionService = DocumentDetectionService.shared
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    private var latestRectObservation: VNRectangleObservation?
    private var isAnalyzingFrame: Bool = false

    public init(
        currentStep: EKYCStep = .welcome,
        documentType: DocumentType = .chipID
    ) {
        self.currentStep = currentStep
        self.documentType = documentType
        cameraService.delegate = self
        self.isCameraPermissionGranted = permissionManager.isPermissionGranted
    }

    // MARK: - Flow Navigation
    public func startFlow() {
        currentStep = .welcome
        capturedDocs = CapturedDocument()
        isCardAligned = false
        errorMessage = nil
        cameraService.stopSession()
    }

    public func proceedFromWelcome() async {
        let granted = await permissionManager.requestPermission()
        self.isCameraPermissionGranted = granted
        if granted {
            startDocumentScan(step: .scanFront)
        } else {
            self.errorMessage = "Cần cấp quyền truy cập Camera để tiếp tục xác thực eKYC."
        }
    }

    public func backToWelcome() {
        cameraService.stopSession()
        withAnimation(.easeInOut(duration: 0.3)) {
            self.currentStep = .welcome
        }
    }

    public func startDocumentScan(step: EKYCStep) {
        currentStep = step
        isCardAligned = false
        documentInstruction = (step == .scanFront) ? "Đặt MẶT TRƯỚC giấy tờ vào khung" : "Đặt MẶT SAU giấy tờ vào khung"
        cameraService.switchCamera(to: .back)
        cameraService.startSession()
    }

    public func captureDocument() async {
        impactFeedback.impactOccurred()
        guard let photo = await cameraService.capturePhoto() else { return }

        let cropped = docDetectionService.cropDocument(from: photo, observation: latestRectObservation)

        if currentStep == .scanFront {
            capturedDocs.frontImage = cropped
            cameraService.stopSession()
            withAnimation(.easeInOut(duration: 0.3)) {
                self.currentStep = .reviewFront
            }
        } else if currentStep == .scanBack {
            capturedDocs.backImage = cropped
            cameraService.stopSession()
            withAnimation(.easeInOut(duration: 0.3)) {
                self.currentStep = .reviewBack
            }
        }
    }

    // MARK: - CameraServiceDelegate Realtime Frame Processing
    public nonisolated func cameraService(_ service: CameraService, didOutput sampleBuffer: CMSampleBuffer, orientation: CGImagePropertyOrientation) {
        Task { @MainActor in
            guard !self.isAnalyzingFrame else { return }
            self.isAnalyzingFrame = true
            defer { self.isAnalyzingFrame = false }

            if self.currentStep == .scanFront || self.currentStep == .scanBack {
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
                let result = self.docDetectionService.detectDocument(in: pixelBuffer, orientation: orientation)
                self.latestRectObservation = result.observation
                self.isCardAligned = result.isAligned
                if result.isAligned {
                    self.documentInstruction = "Giữ yên thẻ để chụp ảnh rõ nét"
                } else {
                    self.documentInstruction = (self.currentStep == .scanFront) ? "Căn chỉnh MẶT TRƯỚC vào khung" : "Căn chỉnh MẶT SAU vào khung"
                }
            }
        }
    }
}

public typealias EKYCWelcomeViewModel = EKYCFlowViewModel
