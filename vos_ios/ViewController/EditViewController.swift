import UIKit
import AVKit
import Photos
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


class EditViewController: UIViewController, NVActivityIndicatorViewable, VideoPlayDelegate, VideoControlDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var playView: VideoPlayView!
    @IBOutlet weak var controlView: VideoControllView!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    var addBackButton: UIButton!
    
    var foreVideoURL: URL?
    var foreVideoAsset: AVAsset!
    var backVideoAsset: AVAsset?
    private var timeObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.foreVideoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/foreVideo.mov")
        
        self.foreVideoAsset = AVAsset(url: self.foreVideoURL!)
        self.playView.setupForeVideo(foreVideo: self.foreVideoAsset)
        self.seekToPos(pos: 0, forVideo: .fore)
        self.playView.delegate = self
        self.controlView.setupForeVideo(foreVideo: self.foreVideoAsset)
        self.controlView.delegate = self
        self.pauseButton.isEnabled = false
        
        let bounds = self.controlView.bounds
        let buttonSize: CGFloat = 40
        self.addBackButton = UIButton(frame: CGRect(x: scrollViewX + scrollViewWidth - buttonSize - 10, y: bounds.height * 0.625 - buttonSize * 0.5, width: buttonSize, height: buttonSize))
        let config =  UIImage.SymbolConfiguration(pointSize: buttonSize, weight: .semibold)
        let buttonImg = UIImage(systemName: "plus.square.fill", withConfiguration: config)
        self.addBackButton.setImage(buttonImg, for: .normal)
        self.addBackButton.addTarget(self, action: #selector(self.addBackVideo(sender:)), for: .touchUpInside)
        self.controlView.addSubview(self.addBackButton)
    }
    
    private func seekToPos(pos: Float, forVideo: WhichVideo) {
        if forVideo == .fore {
            let duration = self.foreVideoAsset.duration
            let time = CMTime(value: CMTimeValue(pos * Float(duration.value)), timescale: duration.timescale)
            self.playView.forePlayer?.seek(to: time, toleranceBefore: timeTolerance, toleranceAfter: timeTolerance)
        } else {
            if self.backVideoAsset == nil {
                return
            }
            let duration = self.backVideoAsset!.duration
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
    
    @objc func addBackVideo(sender: UIButton) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.modalPresentationStyle = .overFullScreen
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.videoExportPreset = AVAssetExportPresetPassthrough
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let videoURL = info[.mediaURL] as! URL
        self.backVideoAsset = AVAsset(url: videoURL)
        self.playView.setupBackVideo(backVideo: self.backVideoAsset!)
        self.seekToPos(pos: 0, forVideo: .back)
        self.controlView.setupBackVideo(backVideo: self.backVideoAsset!)
        self.addBackButton.removeFromSuperview()
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickPlayButton(_ sender: Any) {
        if self.playView.status == .pause {
            self.playView.status = .playing
            self.playButton.isEnabled = false
            self.pauseButton.isEnabled = true
            if self.backVideoAsset != nil {
                let duration = self.backVideoAsset!.duration
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
            else {
                let duration = self.foreVideoAsset.duration
                let endTime = CMTime(value: CMTimeValue(self.controlView.foreClipEndPos * Float(duration.value)), timescale: duration.timescale)
                self.playView.forePlayerItem?.forwardPlaybackEndTime = endTime
                self.playView.forePlayer?.play()
                self.timeObserver = self.playView.forePlayer?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: DispatchQueue.main, using: { [weak self] (time: CMTime) in
                    guard let s = self else { return }
                    let pos = time.seconds / s.foreVideoAsset!.duration.seconds
                    s.videoPlayToTime(pos: Float(pos), forVideo: .back)
                })
                NotificationCenter.default.addObserver(self, selector: #selector(self.forePlayDidEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.playView.forePlayerItem)
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

        if self.backVideoAsset == nil {
            let timeRange = CMTimeRange(start: posToTime(pos: self.controlView.foreClipStartPos, duration: self.foreVideoAsset.duration), end: posToTime(pos: self.controlView.foreClipEndPos, duration: self.foreVideoAsset.duration))
            self.exportToCameraRoll(video: self.foreVideoAsset, timeRange: timeRange)
        }
        else {
            self.exportButton.isEnabled = false
            let compositor = VideoCompositor(frontAsset: self.foreVideoAsset, backAsset: self.backVideoAsset!)
            compositor.frontTimeRange = CMTimeRange(start: posToTime(pos: self.controlView.foreClipStartPos, duration: self.foreVideoAsset.duration), end: posToTime(pos: self.controlView.foreClipEndPos, duration: self.foreVideoAsset.duration))
            compositor.backTimeRange = CMTimeRange(start: posToTime(pos: self.controlView.backClipStartPos, duration: self.backVideoAsset!.duration), end: posToTime(pos: self.controlView.backClipEndPos, duration: self.backVideoAsset!.duration))
            compositor.frontInsertTime = posToTime(pos: self.controlView.foreClipStartPosRelateToBack, duration: compositor.backTimeRange.duration)
            compositor.backInsertTime = .zero
            startAnimating(CGSize(width: 80, height: 80), message: "Exporting...", type: NVActivityIndicatorType.pacman, color: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), backgroundColor: UIColor(displayP3Red: 128, green: 128, blue: 128, alpha: 0.3), textColor: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))
            compositor.makeVideo {
                DispatchQueue.main.async {
                    self.stopAnimating()
                    self.exportSuccessAlert { (action) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func getOutputURL() -> URL? {
        var url: URL? = nil
        do {
            url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            url = url?.appendingPathComponent("export.mov")
        } catch {}
        return url
    }
    
    func exportToCameraRoll(video: AVAsset, timeRange: CMTimeRange) {
        let exporter = AVAssetExportSession(asset: video, presetName: AVAssetExportPresetHEVCHighestQualityWithAlpha)
        let outputURL = self.getOutputURL()
        exporter?.outputURL = outputURL
        exporter?.outputFileType = .mov
        exporter?.timeRange = timeRange
        
        try? FileManager.default.removeItem(at: (exporter?.outputURL)!)
        exporter?.exportAsynchronously {
            if exporter?.status == .failed {
                print(exporter?.description as Any)
                print(exporter.debugDescription)
            } else {
                print("Done! URL=\(String(describing: exporter?.outputURL))")
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
                }) { (success, error) in
                    if success {
                        print("Successfully saved")
                        DispatchQueue.main.async {
                            self.exportSuccessAlert(handler: nil)
                        }
                    } else {
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
    }
    
    func exportSuccessAlert(handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "Finished", message: "Video exported successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func foreIndicatorAlignedNotificationObserved() {
        if self.playView.status == .playing {
            let duration = self.foreVideoAsset.duration
            let endTime = CMTime(value: CMTimeValue(self.controlView.foreClipEndPos * Float(duration.value)), timescale: duration.timescale)
            self.playView.forePlayerItem?.forwardPlaybackEndTime = endTime
            self.playView.forePlayer?.play()
        }
    }
    
    @objc private func forePlayDidEnd() {
        self.playView.status = .pause
        self.playButton.isEnabled = true
        self.pauseButton.isEnabled = false
        self.playView.forePlayer?.removeTimeObserver(self.timeObserver as Any)
        NotificationCenter.default.removeObserver(self)
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
