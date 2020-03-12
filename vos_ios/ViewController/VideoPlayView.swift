import UIKit
import AVFoundation


class VideoPlayView: UIView {
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupVideo(video: AVAsset) {
        self.playerItem = AVPlayerItem(asset: video)
        self.player = AVPlayer(playerItem: self.playerItem)
        self.playerLayer = AVPlayerLayer(player: self.player)
        
        let track = video.tracks.first!
        let resolution = track.naturalSize.applying(track.preferredTransform)
        var viewHeight = CGFloat(0)
        var viewWidth = CGFloat(0)
        var viewX = CGFloat(0)
        var viewY = CGFloat(0)
        if resolution.height < resolution.width {
            viewWidth = self.bounds.width
            viewHeight = resolution.height * viewWidth / resolution.width
            viewX = 0
            viewY = self.bounds.midY - viewHeight / 2
        }
        
        self.playerLayer?.frame = CGRect(x: viewX, y: viewY, width: viewWidth, height: viewHeight)
        self.layer.insertSublayer(self.playerLayer!, at: 0)
        
    }
    
    func seek(toTime: CMTime) {
        self.player?.seek(to: toTime, toleranceBefore: CMTime(value: 1, timescale: 15), toleranceAfter: CMTime(value: 1, timescale: 15))
    }
    
}
