//
//  CameraPermissionManager.swift
//  EKYCExample
//

import AVFoundation
import SwiftUI
import Combine

@MainActor
public final class CameraPermissionManager: ObservableObject {
    @Published public var permissionStatus: AVAuthorizationStatus = .notDetermined
    @Published public var isPermissionGranted: Bool = false

    public static let shared = CameraPermissionManager()

    public init() {
        checkPermission()
    }

    public func checkPermission() {
        #if targetEnvironment(simulator)
        self.permissionStatus = .authorized
        self.isPermissionGranted = true
        #else
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        self.permissionStatus = status
        self.isPermissionGranted = (status == .authorized)
        #endif
    }

    public func requestPermission() async -> Bool {
        #if targetEnvironment(simulator)
        self.permissionStatus = .authorized
        self.isPermissionGranted = true
        return true
        #else
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            self.permissionStatus = .authorized
            self.isPermissionGranted = true
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            self.permissionStatus = granted ? .authorized : .denied
            self.isPermissionGranted = granted
            return granted
        case .denied, .restricted:
            self.permissionStatus = status
            self.isPermissionGranted = false
            return false
        @unknown default:
            self.isPermissionGranted = false
            return false
        }
        #endif
    }
}
