//
//  CameraPreviewView.swift
//  EKYCExample
//

import SwiftUI
import AVFoundation

public struct CameraPreviewView: UIViewRepresentable {
    public let cameraService: CameraService

    public init(cameraService: CameraService) {
        self.cameraService = cameraService
    }

    public func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.backgroundColor = .black
        #if !targetEnvironment(simulator)
        view.videoPreviewLayer.session = cameraService.captureSession
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        #endif
        return view
    }

    public func updateUIView(_ uiView: PreviewUIView, context: Context) {
        #if !targetEnvironment(simulator)
        if uiView.videoPreviewLayer.session != cameraService.captureSession {
            uiView.videoPreviewLayer.session = cameraService.captureSession
        }
        #endif
    }
}

public class PreviewUIView: UIView {
    #if !targetEnvironment(simulator)
    public override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    #else
    private let placeholderLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlaceholder()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlaceholder()
    }

    private func setupPlaceholder() {
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        placeholderLabel.text = "📷 Simulator Camera Feed\n(Visual Preview Active)"
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .lightGray
        placeholderLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    #endif
}
