//
//  EKYCStep.swift
//  EKYCExample
//

import Foundation

public enum EKYCStep: Int, CaseIterable, Identifiable {
    case welcome = 0
    case scanFront = 1
    case reviewFront = 2
    case scanBack = 3
    case reviewBack = 4
    case livenessIntro = 5
    case livenessScan = 6
    case dataConfirmation = 7
    case result = 8

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .welcome:
            return "Chuẩn bị eKYC"
        case .scanFront:
            return "Quét mặt trước"
        case .reviewFront:
            return "Kiểm tra mặt trước"
        case .scanBack:
            return "Quét mặt sau"
        case .reviewBack:
            return "Kiểm tra mặt sau"
        case .livenessIntro:
            return "Xác thực khuôn mặt"
        case .livenessScan:
            return "Kiểm tra Liveness"
        case .dataConfirmation:
            return "Xác nhận thông tin"
        case .result:
            return "Hoàn tất xác thực"
        }
    }

    public var progressIndex: Int {
        switch self {
        case .welcome:
            return 0
        case .scanFront, .reviewFront:
            return 1
        case .scanBack, .reviewBack:
            return 2
        case .livenessIntro, .livenessScan:
            return 3
        case .dataConfirmation, .result:
            return 4
        }
    }

    public static var totalProgressSteps: Int {
        return 4
    }
}
