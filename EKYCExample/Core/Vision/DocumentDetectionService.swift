//
//  DocumentDetectionService.swift
//  EKYCExample
//

import Vision
import UIKit
import CoreImage

public struct DetectedCardResult {
    public let boundingBox: CGRect
    public let confidence: Float
    public let isAligned: Bool
    public let observation: VNRectangleObservation?
}

public final class DocumentDetectionService {
    public static let shared = DocumentDetectionService()

    private let ciContext = CIContext()

    public init() {}

    /// Detect rectangular cards from a CMSampleBuffer or CGImage in realtime
    public func detectDocument(in pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation = .up) -> DetectedCardResult {
        let request = VNDetectRectanglesRequest()
        request.minimumAspectRatio = 1.2
        request.maximumAspectRatio = 1.9
        request.minimumSize = 0.3
        request.maximumObservations = 1
        request.minimumConfidence = 0.6

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        do {
            try handler.perform([request])
            if let observation = request.results?.first {
                let box = observation.boundingBox
                let isAligned = box.width > 0.45 && box.height > 0.25
                return DetectedCardResult(boundingBox: box, confidence: observation.confidence, isAligned: isAligned, observation: observation)
            }
        } catch {
            print("Document detection error: \(error)")
        }

        return DetectedCardResult(boundingBox: .zero, confidence: 0, isAligned: false, observation: nil)
    }

    /// Crop and perspective correct card from full image using VNRectangleObservation
    public func cropDocument(from image: UIImage, observation: VNRectangleObservation?) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        if let obs = observation {
            let imageSize = ciImage.extent.size
            let topLeft = CGPoint(x: obs.topLeft.x * imageSize.width, y: obs.topLeft.y * imageSize.height)
            let topRight = CGPoint(x: obs.topRight.x * imageSize.width, y: obs.topRight.y * imageSize.height)
            let bottomLeft = CGPoint(x: obs.bottomLeft.x * imageSize.width, y: obs.bottomLeft.y * imageSize.height)
            let bottomRight = CGPoint(x: obs.bottomRight.x * imageSize.width, y: obs.bottomRight.y * imageSize.height)

            guard let filter = CIFilter(name: "CIPerspectiveCorrection") else { return image }
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
            filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
            filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
            filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")

            if let outputCI = filter.outputImage,
               let croppedCG = ciContext.createCGImage(outputCI, from: outputCI.extent) {
                return UIImage(cgImage: croppedCG, scale: image.scale, orientation: .up)
            }
        }

        // Fallback: Crop center card frame aspect ratio
        let cardAspectRatio: CGFloat = 85.6 / 53.98 // Standard ISO/IEC 7810 ID-1
        let imgWidth = CGFloat(cgImage.width)
        let imgHeight = CGFloat(cgImage.height)

        let targetWidth = imgWidth * 0.88
        let targetHeight = targetWidth / cardAspectRatio
        let cropX = (imgWidth - targetWidth) / 2
        let cropY = (imgHeight - targetHeight) / 2

        let cropRect = CGRect(x: cropX, y: cropY, width: targetWidth, height: targetHeight)
        if let croppedCG = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
        }

        return image
    }
}
