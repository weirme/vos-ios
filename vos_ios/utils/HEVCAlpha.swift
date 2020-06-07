// Apple - Using HEVC Video with Alpha
// Play, write, and export HEVC video with an alpha channel to add overlay effects to your video processing.
// This sample code project is associated with WWDC 2019 session 506: HEVC Video with Alpha.

import Foundation
import AVFoundation
import VideoToolbox
import CoreImage


// Extension to convert status enums to strings for printing.
extension AVAssetExportSession.Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .waiting: return "waiting"
        case .exporting: return "exporting"
        case .completed: return "completed"
        case .failed: return "failed"
        case .cancelled: return "cancelled"
        @unknown default: return "\(rawValue)"
        }
    }
}


func makeChromaKeyFilter(usingHueFrom minHue: CGFloat,
                         to maxHue: CGFloat,
                         brightnessFrom minBrightness: CGFloat,
                         to maxBrightness: CGFloat) -> CIFilter {
    func getHueAndBrightness(red: CGFloat, green: CGFloat, blue: CGFloat) -> (hue: CGFloat, brightness: CGFloat) {
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        var hue: CGFloat = 0
        var brightness: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: &brightness, alpha: nil)
        return (hue: hue, brightness: brightness)
    }

    let size = 64
    var cubeRGB = [Float]()
    for zaxis in 0 ..< size {
        let blue = CGFloat(zaxis) / CGFloat(size - 1)
        for yaxis in 0 ..< size {
            let green = CGFloat(yaxis) / CGFloat(size - 1)
            for xaxis in 0 ..< size {
                let red = CGFloat(xaxis) / CGFloat(size - 1)

                let (hue, brightness) = getHueAndBrightness(red: red, green: green, blue: blue)
                let alpha: CGFloat = ((minHue <= hue && hue <= maxHue) &&
                    (minBrightness <= brightness && brightness <= maxBrightness)) ? 0: 1

                // Pre-multiplied alpha
                cubeRGB.append(Float(red * alpha))
                cubeRGB.append(Float(green * alpha))
                cubeRGB.append(Float(blue * alpha))
                cubeRGB.append(Float(alpha))
            }
        }
    }

    let data = cubeRGB.withUnsafeBytes { Data($0) }
    let colorCubeFilter = CIFilter(name: "CIColorCube", parameters: ["inputCubeDimension": size, "inputCubeData": data])
    return colorCubeFilter!
}

func removeGreenChroma (sourceURL: URL, destinationURL: URL, handleExportCompletion: @escaping (_ status: AVAssetExportSession.Status) -> Void ) {
    let asset = AVAsset(url: sourceURL)
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHEVCHighestQualityWithAlpha) else {
        print("Failed to create export session to HEVC with alpha.")
        handleExportCompletion(.failed)
        return
    }

    // Setup video composition with green screen removal filter
    let filter = makeChromaKeyFilter(usingHueFrom: 0.3, to: 0.4, brightnessFrom: 0.05, to: 1.0 )
    let chromaKeyComposition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
        let source = request.sourceImage.clampedToExtent()
        filter.setValue(source, forKey: kCIInputImageKey)
        let output = filter.outputImage!
        // Provide the filter output to the composition
        request.finish(with: output, context: nil)
    })

    // Export
    exportSession.outputURL = destinationURL
    exportSession.outputFileType = .mov
    exportSession.videoComposition = chromaKeyComposition
    exportSession.exportAsynchronously {
        handleExportCompletion(exportSession.status)
        if exportSession.status == .failed {
            print(exportSession.error?.localizedDescription as Any)
            print(exportSession.error.debugDescription)
        }
    }
}


func convertToHEVCAlpha(sourceURL: URL, destinationURL: URL) {
    try? FileManager.default.removeItem(at: destinationURL)
    let pendingExports = DispatchGroup()
    pendingExports.enter()
    removeGreenChroma(sourceURL: sourceURL, destinationURL: destinationURL) { status in
        if status == .completed {
            print("Exported successfully")
            convertSemaphore.signal()
        } else {
            print("Export failed with status: \(status)")
        }
        pendingExports.leave()
    }
    pendingExports.wait()
}
