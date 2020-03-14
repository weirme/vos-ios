import UIKit
import AVKit
import ImageScrollView


class EditViewController: UIViewController, VideoControlDelegate {
    
    @IBOutlet weak var PlayView: VideoPlayView!
    @IBOutlet weak var controlView: VideoControllView!
    
    
    var foreVideoAsset: AVAsset!
    var backVideoAsset: AVAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let foreVideoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/foreVideo.mp4")
        let backVideoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/backVideo.mp4")
        
        self.foreVideoAsset = AVAsset(url: foreVideoURL)
        self.backVideoAsset = AVAsset(url: backVideoURL)
        self.controlView.setupVideo(foreVideo: self.foreVideoAsset, backVideo: self.backVideoAsset)
        self.controlView.delegate = self
        self.PlayView.setupVideo(video: self.foreVideoAsset)
    }
    
    func videoSeekToTime(pos: Float) {
        let duration = self.foreVideoAsset.duration
        let time = CMTime(value: CMTimeValue(pos * Float(duration.value)), timescale: duration.timescale)
        self.PlayView.seek(toTime: time)
    }
    
}
