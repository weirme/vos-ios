import UIKit
import AVKit
import ImageScrollView


class EditViewController: UIViewController, VideoScrollDelegate {
    
    @IBOutlet weak var PlayView: VideoPlayView!
    @IBOutlet weak var controlScrollView: UIView!
    @IBOutlet weak var foreScrollView: VideoScrollView!
    @IBOutlet weak var backScrollView: VideoScrollView!
    @IBOutlet weak var timeIndicatorView: IndicatorLineView!
    
    var foreVideoAsset: AVAsset!
    var backVideoAsset: AVAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controlScrollPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.controlScrollPanAction(pan:)))
        self.controlScrollView.addGestureRecognizer(controlScrollPanGesture)
        self.controlScrollView.isUserInteractionEnabled = true
        
        let videoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/video.mp4")
        
        self.foreVideoAsset = AVAsset(url: videoURL)
        self.foreScrollView.displayVideo(video: self.foreVideoAsset)
        self.foreScrollView.offset = CGPoint(x: self.foreScrollView.scrollView.frame.minX - self.timeIndicatorView.frame.midX, y: 0)
        self.foreScrollView.delegate = self
        self.PlayView.setupVideo(video: self.foreVideoAsset)
        
        self.backVideoAsset = AVAsset(url: videoURL)
        self.backScrollView.displayVideo(video: self.backVideoAsset)
        self.backScrollView.offset = CGPoint(x: self.backScrollView.scrollView.frame.minX - self.timeIndicatorView.frame.midX, y: 0)
        
    }
    
    @objc func controlScrollPanAction(pan: UIPanGestureRecognizer) {
        let trans: CGPoint = pan.translation(in: pan.view)
        let foreOffset: CGPoint = self.foreScrollView.offset
        let backOffset: CGPoint = self.backScrollView.offset
        var deltaOffsetX: CGFloat = 0
        if trans.x < 0 {
            deltaOffsetX = -max(trans.x, min(foreOffset.x, backOffset.x))
        } else {
            deltaOffsetX = -min(trans.x, max(foreOffset.x, backOffset.x))
        }
        self.foreScrollView.offset = CGPoint(x: foreOffset.x + deltaOffsetX, y: foreOffset.y)
        self.backScrollView.offset = CGPoint(x: backOffset.x + deltaOffsetX, y: backOffset.y)
    }
    
    func videoScrollToTime(videoScrollView: VideoScrollView, pos: Float) {
        let duration = self.foreVideoAsset.duration
        let time = CMTime(value: CMTimeValue(pos * Float(duration.value)), timescale: duration.timescale)
        self.PlayView.seek(toTime: time)
    }
    
}
