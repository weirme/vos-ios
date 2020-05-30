import Foundation
import AVFoundation
import UIKit


class VideoCompositor {
    var frontAsset: AVAsset
    var backAsset: AVAsset
    var frontInsertTime: CMTime = .zero
    var backInsertTime: CMTime = .zero
    var frontTimeRange: CMTimeRange
    var backTimeRange: CMTimeRange
    var outputURL: URL?
    
    init(frontAsset: AVAsset, backAsset: AVAsset) {
        self.frontAsset = frontAsset
        self.frontTimeRange = CMTimeRange(start: .zero, duration: self.frontAsset.duration)
        self.backAsset = backAsset
        self.backTimeRange = CMTimeRange(start: .zero, duration: self.backAsset.duration)
        self.outputURL = VideoCompositor.getOutputURL()!
    }
    
    func makeVideo() {
        let composition = AVMutableComposition()
        self.addAsset(asset: self.frontAsset, toComposition: composition, trackID: 1, atTime: self.frontInsertTime, timeRange: self.frontTimeRange)
        self.addAsset(asset: self.backAsset, toComposition: composition, trackID: 2, atTime: self.backInsertTime, timeRange: self.backTimeRange)
        
        let backVideoTrack = self.backAsset.tracks.first!
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = backVideoTrack.naturalSize
        videoComposition.frameDuration = CMTime(seconds: 1.0 / Double(backVideoTrack.nominalFrameRate), preferredTimescale: backVideoTrack.naturalTimeScale)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = composition.tracks.first!.timeRange
        let frontLayerInstruction = AVMutableVideoCompositionLayerInstruction()
        frontLayerInstruction.trackID = 1
        let backLayerInstruction = AVMutableVideoCompositionLayerInstruction()
        backLayerInstruction.trackID = 2
        instruction.layerInstructions = [frontLayerInstruction, backLayerInstruction]
        videoComposition.instructions = [instruction]
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHEVCHighestQualityWithAlpha)
        exporter?.outputURL = self.outputURL
        exporter?.outputFileType = .mov
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = videoComposition
        do {
            try FileManager.default.removeItem(at: (exporter?.outputURL)!)
        } catch {}
        exporter?.exportAsynchronously {
            if exporter?.status == .failed {
                print(exporter?.description)
                print(exporter.debugDescription)
            } else {
                print("Done! URL=\(exporter?.outputURL)")
            }
        }
    }
    
    func addAsset(asset: AVAsset, toComposition: AVMutableComposition, trackID: CMPersistentTrackID, atTime: CMTime, timeRange: CMTimeRange) {
        let videoTrack = toComposition.addMutableTrack(withMediaType: .video, preferredTrackID: trackID)
        do {
            if let assetVideoTrack = asset.tracks.first {
                try videoTrack?.insertTimeRange(timeRange, of: assetVideoTrack, at: atTime)
            }
        } catch {}
    }
    
    static func getOutputURL() -> URL? {
        var url: URL? = nil
        do {
            url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            url = url?.appendingPathComponent("export.mov")
        } catch {}
        return url
    }
    
    static func maskLayerWithFrame(frame: CGRect) -> CALayer {
        let path = UIBezierPath(ovalIn: frame.insetBy(dx: frame.width / 10, dy: frame.height / 10))
        let layer = CAShapeLayer()
        layer.frame = frame
        layer.path = path.cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        layer.strokeColor = nil
        layer.fillColor = UIColor.white.cgColor
        return layer
    }
    
}
