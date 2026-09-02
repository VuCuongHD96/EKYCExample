//
//  CameraService.swift
//  EKYCExample
//

import AVFoundation
import UIKit
import Combine

public protocol CameraServiceDelegate: AnyObject {
    func cameraService(_ service: CameraService, didOutput sampleBuffer: CMSampleBuffer, orientation: CGImagePropertyOrientation)
}

public final class CameraService: NSObject, ObservableObject {
    @Published public var isSessionRunning: Bool = false
    @Published public var isTorchOn: Bool = false
    @Published public var currentPosition: AVCaptureDevice.Position = .back

    public weak var delegate: CameraServiceDelegate?

    public let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "ekyc.camera.sessionQueue")
    private let videoDataOutputQueue = DispatchQueue(label: "ekyc.camera.videoDataOutputQueue", qos: .userInteractive)

    private var activeDeviceInput: AVCaptureDeviceInput?
    private var photoContinuation: CheckedContinuation<UIImage?, Never>?

    public override init() {
        super.init()
    }

    public func configureSession(position: AVCaptureDevice.Position = .back) {
        #if targetEnvironment(simulator)
        Task { @MainActor in
            self.currentPosition = position
            self.isSessionRunning = true
        }
        #else
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high

            // Setup input device
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                self.captureSession.commitConfiguration()
                return
            }

            if let currentInput = self.activeDeviceInput {
                self.captureSession.removeInput(currentInput)
            }

            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
                self.activeDeviceInput = input
            }

            // Setup Photo Output
            if !self.captureSession.outputs.contains(self.photoOutput) {
                if self.captureSession.canAddOutput(self.photoOutput) {
                    self.photoOutput.isHighResolutionCaptureEnabled = true
                    self.captureSession.addOutput(self.photoOutput)
                }
            }

            // Setup Video Data Output for Realtime Vision
            if !self.captureSession.outputs.contains(self.videoDataOutput) {
                self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
                self.videoDataOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
                ]
                self.videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
                if self.captureSession.canAddOutput(self.videoDataOutput) {
                    self.captureSession.addOutput(self.videoDataOutput)
                }
            }

            self.captureSession.commitConfiguration()

            Task { @MainActor in
                self.currentPosition = position
            }
        }
        #endif
    }

    public func startSession() {
        #if targetEnvironment(simulator)
        Task { @MainActor in
            self.isSessionRunning = true
        }
        #else
        sessionQueue.async { [weak self] in
            guard let self = self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
            Task { @MainActor in
                self.isSessionRunning = true
            }
        }
        #endif
    }

    public func stopSession() {
        #if targetEnvironment(simulator)
        Task { @MainActor in
            self.isSessionRunning = false
        }
        #else
        sessionQueue.async { [weak self] in
            guard let self = self, self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
            Task { @MainActor in
                self.isSessionRunning = false
                self.isTorchOn = false
            }
        }
        #endif
    }

    public func switchCamera(to position: AVCaptureDevice.Position) {
        configureSession(position: position)
    }

    public func toggleTorch() {
        #if !targetEnvironment(simulator)
        guard let device = activeDeviceInput?.device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
                Task { @MainActor in self.isTorchOn = false }
            } else if device.isTorchModeSupported(.on) {
                try device.setTorchModeOn(level: 1.0)
                Task { @MainActor in self.isTorchOn = true }
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch error: \(error.localizedDescription)")
        }
        #endif
    }

    public func capturePhoto() async -> UIImage? {
        #if targetEnvironment(simulator)
        return generateMockImage()
        #else
        return await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: nil)
                    return
                }
                let settings = AVCapturePhotoSettings()
                settings.photoQualityPrioritization = .balanced
                self.photoContinuation = continuation
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
        #endif
    }

    #if targetEnvironment(simulator)
    private func generateMockImage() -> UIImage {
        let size = CGSize(width: 800, height: 600)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        UIColor.systemBlue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        let text = self.currentPosition == .front ? "Ảnh Selfie Mock" : "Ảnh CCCD Mặt Trước/Sau Mock"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 32)
        ]
        let textSize = text.size(withAttributes: attributes)
        let rect = CGRect(x: (size.width - textSize.width)/2, y: (size.height - textSize.height)/2, width: textSize.width, height: textSize.height)
        text.draw(in: rect, withAttributes: attributes)

        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    #endif
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("--- debug --- CameraService --- captureOutput")
        print("--- debug --- output = \(output)")
        print("--- debug --- sampleBuffer = \(sampleBuffer)")
        print("--- debug --- connection = \(connection)")
        let orientation: CGImagePropertyOrientation = (currentPosition == .front) ? .leftMirrored : .right
        delegate?.cameraService(self, didOutput: sampleBuffer, orientation: orientation)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            photoContinuation?.resume(returning: nil)
            photoContinuation = nil
            return
        }

        // Correct image orientation if needed
        let fixedImage = image.fixedOrientation()
        photoContinuation?.resume(returning: fixedImage)
        photoContinuation = nil
    }
}

// MARK: - UIImage Orientation Helper
public extension UIImage {
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
