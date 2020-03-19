import UIKit
import AVKit
import ImageScrollView


enum WhichVideo {
    case fore
    case back
}

class EditViewController: UIViewController, VideoPlayDelegate, VideoControlDelegate {
    
    
    @IBOutlet weak var playView: VideoPlayView!
    @IBOutlet weak var controlView: VideoControllView!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    
    var foreVideoAsset: AVAsset!
    var backVideoAsset: AVAsset!
    private var timeObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let foreVideoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/foreVideo.mp4")
        let backVideoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/backVideo.mp4")
        
        self.foreVideoAsset = AVAsset(url: foreVideoURL)
        self.backVideoAsset = AVAsset(url: backVideoURL)
        self.playView.setupVideo(foreVideo: self.foreVideoAsset, backVideo: self.backVideoAsset)
        self.seekToPos(pos: 0, forVideo: .fore)
        self.playView.delegate = self
        self.controlView.setupVideo(foreVideo: self.foreVideoAsset, backVideo: self.backVideoAsset)
        self.seekToPos(pos: 0, forVideo: .back)
        self.controlView.delegate = self
        self.pauseButton.isEnabled = false
    }
    
    private func seekToPos(pos: Float, forVideo: WhichVideo) {
        if forVideo == .fore {
            let duration = self.foreVideoAsset.duration
            let time = CMTime(value: CMTimeValue(pos * Float(duration.value)), timescale: duration.timescale)
            self.playView.forePlayer?.seek(to: time, toleranceBefore: timeTolerance, toleranceAfter: timeTolerance)
        } else {
            let duration = self.backVideoAsset.duration
            let time = CMTime(value: CMTimeValue(pos * Float(duration.value)), timescale: duration.timescale)
            self.playView.backPlayer?.seek(to: time, toleranceBefore: timeTolerance, toleranceAfter: timeTolerance)
        }
    }
    
    func videoPlayToTime(pos: Float, forVideo: WhichVideo) {
        if self.playView.status == .playing {
            self.controlView.scrollToPos(pos: pos, forVideo: forVideo)
        }
    }
    
    func videoScrollToTime(pos: Float, forVideo: WhichVideo) {
        if self.playView.status == .pause {
            self.seekToPos(pos: pos, forVideo: forVideo)
        }
    }
    
    @IBAction func clickPlayButton(_ sender: Any) {
        if self.playView.status == .pause {
            self.playView.status = .playing
            self.playButton.isEnabled = false
            self.pauseButton.isEnabled = true
            let duration = self.backVideoAsset.duration
            let endTime = CMTime(value: CMTimeValue(self.controlView.backClipEndPos * Float(duration.value)), timescale: duration.timescale)
            self.playView.backPlayerItem?.forwardPlaybackEndTime = endTime
            self.playView.backPlayer?.play()
            self.timeObserver = self.playView.backPlayer?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: DispatchQueue.main, using: { [weak self] (time: CMTime) in
                guard let s = self else { return }
                let pos = time.seconds / s.backVideoAsset!.duration.seconds
                s.videoPlayToTime(pos: Float(pos), forVideo: .back)
            })
            NotificationCenter.default.addObserver(self, selector: #selector(self.backPlayDidEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.playView.backPlayerItem)
            
            if self.controlView.foreReadyToPlay {
                self.playView.forePlayer?.play()
            } else {
                self.seekToPos(pos: self.controlView.foreClipStartPos, forVideo: .fore)
                let name = Notification.Name("ForeIndicatorAlignedNotification")
                NotificationCenter.default.addObserver(self, selector: #selector(self.foreIndicatorAlignedNotificationObserved), name: name, object: nil)
            }
        }
    }
    
    @IBAction func clickPauseButton(_ sender: Any) {
        if self.playView.status == .playing {
            self.playView.status = .pause
            self.playButton.isEnabled = true
            self.pauseButton.isEnabled = false
            self.playView.forePlayer?.pause()
            self.playView.backPlayer?.pause()
        self.playView.backPlayer?.removeTimeObserver(self.timeObserver as Any)
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
    @objc private func foreIndicatorAlignedNotificationObserved() {
        if self.playView.status == .playing {
            let duration = self.foreVideoAsset.duration
            let endTime = CMTime(value: CMTimeValue(self.controlView.foreClipEndPos * Float(duration.value)), timescale: duration.timescale)
            self.playView.forePlayerItem?.forwardPlaybackEndTime = endTime
            self.playView.forePlayer?.play()
        }
    }
    
    @objc private func backPlayDidEnd() {
        self.playView.status = .pause
        self.playButton.isEnabled = true
        self.pauseButton.isEnabled = false
        self.playView.forePlayer?.pause()
        self.playView.backPlayer?.removeTimeObserver(self.timeObserver as Any)
        NotificationCenter.default.removeObserver(self)
    }
    
}
