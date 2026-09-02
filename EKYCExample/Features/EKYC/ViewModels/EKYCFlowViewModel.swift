//
//  EKYCFlowViewModel.swift
//  EKYCExample
//

import SwiftUI
import Combine

@MainActor
public final class EKYCFlowViewModel: ObservableObject {
    // MARK: - Published Flow States
    @Published public var currentStep: EKYCStep = .welcome
    @Published public var documentType: DocumentType = .chipID
    @Published public var isCameraPermissionGranted: Bool = false
    @Published public var errorMessage: String?

    public init(
        currentStep: EKYCStep = .welcome,
        documentType: DocumentType = .chipID
    ) {
        self.currentStep = currentStep
        self.documentType = documentType
    }

    // MARK: - Welcome Step Actions
    public func startFlow() {
        currentStep = .welcome
        errorMessage = nil
    }

    public func proceedFromWelcome() async {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.currentStep = .scanFront
        }
    }

    public func backToWelcome() {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.currentStep = .welcome
        }
    }
}

public typealias EKYCWelcomeViewModel = EKYCFlowViewModel
