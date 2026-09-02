//
//  DocumentType.swift
//  EKYCExample
//

import Foundation

public enum DocumentType: String, CaseIterable, Identifiable {
    case chipID = "CCCD Gắn Chip"
    case citizenID = "CCCD / CMND 12 số"
    case oldID = "CMND 9 số"
    case passport = "Hộ Chiếu (Passport)"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .chipID:
            return "creditcard.and.123"
        case .citizenID:
            return "person.text.rectangle"
        case .oldID:
            return "doc.text.image"
        case .passport:
            return "book.closed"
        }
    }

    public var description: String {
        switch self {
        case .chipID:
            return "Căn cước công dân gắn chip điện tử mới nhất"
        case .citizenID:
            return "Thẻ căn cước công dân mã vạch hoặc CMND 12 số"
        case .oldID:
            return "Chứng minh nhân dân loại cũ 9 số"
        case .passport:
            return "Hộ chiếu Việt Nam còn hạn sử dụng"
        }
    }
    
    public var hasBackSide: Bool {
        switch self {
        case .passport:
            return false
        default:
            return true
        }
    }
}
