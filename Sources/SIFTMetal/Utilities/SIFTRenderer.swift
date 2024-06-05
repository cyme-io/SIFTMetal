import CoreGraphics
import Cocoa


public final class SIFTRenderer {
    
    public init() {
        
    }
    
    public func drawKeypoints(
        sourceImage: CGImage,
        overlayColor: CGColor = CGColor.black.copy(alpha: 0.8)!,
        referenceColor: CGColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
        foundColor: CGColor = CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
        referenceKeypoints: [SIFTKeypoint],
        foundKeypoints: [SIFTKeypoint]
    ) -> CGImage? {
        
        let bounds = CGRect(x: 0, y: 0, width: sourceImage.width, height: sourceImage.height)
        
        if let cgContext = CGContext(
                   data: nil,
                   width: sourceImage.width,
                   height: sourceImage.height,
                   bitsPerComponent: sourceImage.bitsPerComponent,
                   bytesPerRow: 0, // will cause the correct value to be computed
                   space: sourceImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                   bitmapInfo: sourceImage.bitmapInfo.rawValue) {
            
            
            cgContext.saveGState()
            cgContext.scaleBy(x: 1, y: -1)
            cgContext.translateBy(x: 0, y: -bounds.height)
            cgContext.draw(sourceImage, in: bounds)
            cgContext.restoreGState()
            
            cgContext.saveGState()
            cgContext.setBlendMode(.multiply)
            cgContext.setFillColor(overlayColor)
            cgContext.fill([bounds])
            cgContext.restoreGState()
            
            cgContext.saveGState()
            cgContext.setLineWidth(1)
            cgContext.setStrokeColor(referenceColor)
            //        cgContext.setBlendMode(.screen)
            for keypoint in referenceKeypoints {
                let radius = CGFloat(keypoint.sigma)
                let bounds = CGRect(
                    x: CGFloat(keypoint.absoluteCoordinate.x) - radius,
                    y: CGFloat(keypoint.absoluteCoordinate.y) - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                cgContext.addEllipse(in: bounds)
            }
            cgContext.strokePath()
            cgContext.restoreGState()
            
            
            cgContext.saveGState()
            cgContext.setLineWidth(1)
            cgContext.setStrokeColor(foundColor)
            cgContext.setBlendMode(.screen)
            for keypoint in foundKeypoints {
                let radius = CGFloat(keypoint.sigma)
                let bounds = CGRect(
                    x: CGFloat(keypoint.absoluteCoordinate.x) - radius,
                    y: CGFloat(keypoint.absoluteCoordinate.y) - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                cgContext.addEllipse(in: bounds)
            }
            cgContext.strokePath()
            cgContext.restoreGState()
            
            return cgContext.makeImage()
        } else {
            // failed to render
            return sourceImage
        }
    }


    func drawDescriptors(
        sourceImage: CGImage,
        overlayColor: CGColor = CGColor.black.copy(alpha: 0.8)!,
        referenceColor: CGColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
        foundColor: CGColor = CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
        referenceDescriptors: [SIFTDescriptor],
        foundDescriptors: [SIFTDescriptor]
    ) -> CGImage? {
        
        let bounds = CGRect(x: 0, y: 0, width: sourceImage.width, height: sourceImage.height)

        if let cgContext = CGContext(
                   data: nil,
                   width: sourceImage.width,
                   height: sourceImage.height,
                   bitsPerComponent: sourceImage.bitsPerComponent,
                   bytesPerRow: 0, // will cause the correct value to be computed
                   space: sourceImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                   bitmapInfo: sourceImage.bitmapInfo.rawValue) {

            cgContext.saveGState()
            cgContext.scaleBy(x: 1, y: -1)
            cgContext.translateBy(x: 0, y: -bounds.height)
            cgContext.draw(sourceImage, in: bounds)
            cgContext.restoreGState()
                    
            cgContext.saveGState()
            cgContext.setBlendMode(.multiply)
            cgContext.setFillColor(overlayColor)
            cgContext.fill([bounds])
            cgContext.restoreGState()

            drawDescriptors(cgContext: cgContext, color: referenceColor, descriptors: referenceDescriptors)
            
            drawDescriptors(cgContext: cgContext, color: foundColor, descriptors: foundDescriptors)
            
            return cgContext.makeImage()
            
        } else {
            return sourceImage
        }
    }


    public func drawMatches(
        sourceImage: CGImage,
        targetImage: CGImage,
        overlayColor: CGColor = CGColor.black.copy(alpha: 0.8)!,
        sourceColor: CGColor = CGColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),
        targetColor: CGColor = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),
        matches: [SIFTCorrespondence]
    ) -> CGImage? {
        
        precondition(targetImage.width == sourceImage.width)
        precondition(targetImage.height == sourceImage.height)
        let imageSize = CGSize(width: sourceImage.width, height: sourceImage.height)
        let bounds = CGRect(x: 0, y: 0, width: imageSize.width * 2, height: imageSize.height)
        
        let sourceOffset = CGPoint(x: 0, y: 0)
        let targetOffset = CGPoint(x: imageSize.width, y: 0)
        let sourceBounds = CGRect(origin: sourceOffset, size: imageSize)
        let targetBounds = CGRect(origin: targetOffset, size: imageSize)

        let sourceDescriptors = matches.map { $0.source }
        let targetDescriptors = matches.map { $0.target }
        
        let colors: [CGColor] = [
            NSColor.systemRed, NSColor.systemOrange, NSColor.systemYellow, NSColor.systemGreen, NSColor.systemTeal, NSColor.systemBlue, NSColor.systemPurple, NSColor.systemIndigo
        ].map { $0.cgColor }
        let radius = CGFloat(2)

        if let cgContext = CGContext(
                   data: nil,
                   width: Int(bounds.width),
                   height: Int(bounds.height),
                   bitsPerComponent: sourceImage.bitsPerComponent,
                   bytesPerRow: 0, // will cause the correct value to be computed
                   space: sourceImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                   bitmapInfo: sourceImage.bitmapInfo.rawValue) {

            // Draw images
            cgContext.saveGState()
            cgContext.scaleBy(x: 1, y: -1)
            cgContext.translateBy(x: 0, y: -bounds.height)
            cgContext.draw(sourceImage, in: sourceBounds)
            cgContext.draw(targetImage, in: targetBounds)
            cgContext.restoreGState()

            // Overlay
            cgContext.saveGState()
            cgContext.setBlendMode(.multiply)
            cgContext.setFillColor(overlayColor)
            cgContext.fill([bounds])
            cgContext.restoreGState()

            // Descriptors
            drawDescriptors(cgContext: cgContext, at: sourceOffset, color: sourceColor, descriptors: sourceDescriptors)
            drawDescriptors(cgContext: cgContext, at: targetOffset, color: targetColor, descriptors: targetDescriptors)
            
            cgContext.saveGState()
            cgContext.setLineWidth(1)
            cgContext.setBlendMode(.screen)

            for i in 0 ..< matches.count {
                let n = i % (colors.count - 1)
                let color = colors[n]
                
                let match = matches[i]
                let ks = match.source.keypoint.absoluteCoordinate
                let kt = match.target.keypoint.absoluteCoordinate
                let ps = CGPoint(
                    x: sourceOffset.x + CGFloat(ks.x),
                    y: sourceOffset.y + CGFloat(ks.y)
                )
                let pt = CGPoint(
                    x: targetOffset.x + CGFloat(kt.x),
                    y: targetOffset.y + CGFloat(kt.y)
                )
//                let bs = CGRect(
//                    x: ps.x - radius,
//                    y: ps.y - radius,
//                    width: radius * 2,
//                    height: radius * 2
//                )
//                let bt = CGRect(
//                    x: pt.x - radius,
//                    y: pt.y - radius,
//                    width: radius * 2,
//                    height: radius * 2
//                )

                cgContext.move(to: ps)
                cgContext.addLine(to: pt)

                if i % 10 == 0 {
                    cgContext.setLineWidth(2)
                    cgContext.setStrokeColor(color.copy(alpha: 0.5)! )
                }
                else {
                    cgContext.setLineWidth(0.5)
                    cgContext.setStrokeColor(color.copy(alpha: 0.3)!)
                }
                
                cgContext.strokePath()
            }
            
            cgContext.restoreGState()

            return cgContext.makeImage()
        } else {
            return nil
        }
    }


    private func drawDescriptors(
        cgContext: CGContext,
        at offset: CGPoint = .zero,
        color: CGColor,
        descriptors: [SIFTDescriptor]
    ) {
        cgContext.saveGState()
        cgContext.setLineWidth(0.5)
        cgContext.setStrokeColor(color)
        cgContext.setBlendMode(.screen)
        for descriptor in descriptors {
            let keypoint = descriptor.keypoint
            let radius = 1.5 * CGFloat(keypoint.sigma)
            let center = CGPoint(
                x: offset.x + CGFloat(keypoint.absoluteCoordinate.x),
                y: offset.y + CGFloat(keypoint.absoluteCoordinate.y)
            )
            let bounds = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )
            cgContext.addEllipse(in: bounds)
            
            // Primary Orientation
            cgContext.move(to: center)
            cgContext.addLine(
                to: CGPoint(
                    x: center.x + cos(CGFloat(descriptor.theta)) * radius,
                    y: center.y + sin(CGFloat(descriptor.theta)) * radius
                )
            )
            
            //
        }
        cgContext.strokePath()
        cgContext.restoreGState()
    }
}
