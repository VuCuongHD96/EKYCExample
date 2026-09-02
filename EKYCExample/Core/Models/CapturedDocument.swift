//
//  CapturedDocument.swift
//  EKYCExample
//

import UIKit

public struct CapturedDocument {
    public var frontImage: UIImage?
    public var backImage: UIImage?
    public var selfieImage: UIImage?
    public var croppedAvatar: UIImage?

    public var isFrontCaptured: Bool { frontImage != nil }
    public var isBackCaptured: Bool { backImage != nil }
    public var isSelfieCaptured: Bool { selfieImage != nil }

    public init(
        frontImage: UIImage? = nil,
        backImage: UIImage? = nil,
        selfieImage: UIImage? = nil,
        croppedAvatar: UIImage? = nil
    ) {
        self.frontImage = frontImage
        self.backImage = backImage
        self.selfieImage = selfieImage
        self.croppedAvatar = croppedAvatar
    }
}
