import Foundation
import AVFoundation
import UIKit
import Photos


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
    
    func makeVideo(completionHandler: @escaping () -> ()) {
        let composition = AVMutableComposition()
        
        // Tracks
        self.addAsset(asset: self.frontAsset, toComposition: composition, trackID: 1, atTime: self.frontInsertTime, timeRange: self.frontTimeRange)
        self.addAsset(asset: self.backAsset, toComposition: composition, trackID: 2, atTime: self.backInsertTime, timeRange: self.backTimeRange)
        
        // Layer Instruction
        let frontLayerInstruction = AVMutableVideoCompositionLayerInstruction()
        frontLayerInstruction.trackID = 1
        frontLayerInstruction.setOpacity(0, at: self.frontInsertTime + self.frontTimeRange.duration)
        let backLayerInstruction = AVMutableVideoCompositionLayerInstruction()
        backLayerInstruction.trackID = 2
        
        // Instruction
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: self.backAsset.duration)
        instruction.layerInstructions = [frontLayerInstruction, backLayerInstruction]
        
        // Composition
        let backVideoTrack = self.backAsset.tracks.first!
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = backVideoTrack.naturalSize
        videoComposition.frameDuration = CMTime(seconds: 1.0 / Double(backVideoTrack.nominalFrameRate), preferredTimescale: backVideoTrack.naturalTimeScale)
        videoComposition.instructions = [instruction]
        
        // Exporter
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
                print(exporter?.description as Any)
                print(exporter.debugDescription)
            } else {
                print("Done! URL=\(String(describing: exporter?.outputURL))")
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.outputURL!)
                }) { (success, error) in
                    if success {
                        print("Successfully saved.")
                    } else {
                        print(error?.localizedDescription as Any)
                    }
                }
                completionHandler()
            }
        }
    }
    
    func addAsset(asset: AVAsset, toComposition: AVMutableComposition, trackID: CMPersistentTrackID, atTime: CMTime, timeRange: CMTimeRange) {
        let videoTrack = toComposition.addMutableTrack(withMediaType: .video, preferredTrackID: trackID)
        do {
            if let assetVideoTrack = asset.tracks.first {
                try videoTrack?.insertTimeRange(timeRange, of: assetVideoTrack, at: atTime)
            }
        } catch {
            print("An error occured.")
        }
    }
    
    static func getOutputURL() -> URL? {
        var url: URL? = nil
        do {
            url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            url = url?.appendingPathComponent("export.mov")
        } catch {}
        return url
    }
    
}
