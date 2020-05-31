import UIKit
import AVKit
import ImageScrollView
import NVActivityIndicatorView



enum WhichVideo {
    case fore
    case back
}

func posToTime(pos: Float, duration: CMTime) -> CMTime {
    let time = CMTime(value: CMTimeValue(pos * Float(duration.value)), timescale: duration.timescale)
    return time
}


class EditViewController: UIViewController, NVActivityIndicatorViewable, VideoPlayDelegate, VideoControlDelegate {
    
    
    @IBOutlet weak var playView: VideoPlayView!
    @IBOutlet weak var controlView: VideoControllView!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    
    var foreVideoAsset: AVAsset!
    var backVideoAsset: AVAsset!
    private var timeObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let foreVideoNoAlphaURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/swan.mp4")
        let foreVideoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/foreVideo.mp4")
        let backVideoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/backVideo.mp4")
        
//        convertToHEVCAlpha(sourceURL: foreVideoNoAlphaURL, destinationURL: foreVideoURL)
        
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
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func export(_ sender: Any) {
        print("Exporting start...")
        self.exportButton.isEnabled = false
        let compositor = VideoCompositor(frontAsset: self.foreVideoAsset, backAsset: self.backVideoAsset)
        compositor.frontTimeRange = CMTimeRange(start: posToTime(pos: self.controlView.foreClipStartPos, duration: self.foreVideoAsset.duration), end: posToTime(pos: self.controlView.foreClipEndPos, duration: self.foreVideoAsset.duration))
        compositor.backTimeRange = CMTimeRange(start: posToTime(pos: self.controlView.backClipStartPos, duration: self.backVideoAsset.duration), end: posToTime(pos: self.controlView.backClipEndPos, duration: self.backVideoAsset.duration))
        compositor.frontInsertTime = posToTime(pos: self.controlView.foreClipStartPosRelateToBack, duration: compositor.backTimeRange.duration)
        compositor.backInsertTime = .zero
        startAnimating(CGSize(width: 80, height: 80), message: "Exporting...", type: NVActivityIndicatorType.pacman, color: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), backgroundColor: UIColor(displayP3Red: 128, green: 128, blue: 128, alpha: 0.3), textColor: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))
        compositor.makeVideo {
            self.stopAnimating()
            let alert = UIAlertController(title: "Finished", message: "Video exported successfully.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
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
