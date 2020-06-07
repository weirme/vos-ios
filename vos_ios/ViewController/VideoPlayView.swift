import UIKit
import AVFoundation


enum VideoPlayerStatus {
    case playing
    case pause
}

protocol VideoPlayDelegate {
    func videoPlayToTime(pos: Float, forVideo: WhichVideo)
}

class VideoPlayView: UIView {
    
    var foreVideoAsset: AVAsset?
    var forePlayerItem: AVPlayerItem?
    var forePlayer: AVPlayer?
    var forePlayerLayer: AVPlayerLayer?
    var backVideoAsset: AVAsset?
    var backPlayerItem: AVPlayerItem?
    var backPlayer: AVPlayer?
    var backPlayerLayer: AVPlayerLayer?
    
    var status: VideoPlayerStatus = .pause
    var delegate: VideoPlayDelegate?
    private var timeObserver: Any?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupForeVideo(foreVideo: AVAsset) {
        self.foreVideoAsset = foreVideo
        self.forePlayerItem = AVPlayerItem(asset: self.foreVideoAsset!)
        self.forePlayer = AVPlayer(playerItem: self.forePlayerItem)
        self.forePlayerLayer = AVPlayerLayer(player: self.forePlayer)
        
        self.forePlayerLayer?.frame = self.makeFrame(video: self.foreVideoAsset!)
        self.layer.insertSublayer(self.forePlayerLayer!, at: 1)
        
        let name = Notification.Name("ForeIndicatorAlignedNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(self.foreIndicatorAlignedNotificationObserved), name: name, object: nil)
    }
    
    func setupBackVideo(backVideo: AVAsset) {
        self.backVideoAsset = backVideo
        self.backPlayerItem = AVPlayerItem(asset: self.backVideoAsset!)
        self.backPlayer = AVPlayer(playerItem: self.backPlayerItem)
        self.backPlayerLayer = AVPlayerLayer(player: self.backPlayer)
        self.backPlayerLayer?.frame = makeFrame(video: self.backVideoAsset!)
        self.layer.insertSublayer(self.backPlayerLayer!, at: 0)
        
        let name = Notification.Name("BackIndicatorAlignedNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(self.backIndicatorAlignedNotificationObserved), name: name, object: nil)
    }
    
    func makeFrame(video: AVAsset) -> CGRect {
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
        } else {
            // todo
        }
        return CGRect(x: viewX, y: viewY, width: viewWidth, height: viewHeight)
    }
    
    @objc private func foreIndicatorAlignedNotificationObserved(notification: Notification) {
        let state = notification.userInfo?["state"] as! Bool
        self.forePlayerLayer?.isHidden = state
    }
    
    @objc private func backIndicatorAlignedNotificationObserved(notification: Notification) {
        let state = notification.userInfo?["state"] as! Bool
        self.backPlayerLayer?.isHidden = state
    }
}
