import UIKit
import AVKit
import ImageScrollView


class EditViewController: UIViewController, VideoScrollDelegate {
    
    @IBOutlet weak var PlayView: VideoPlayView!
    @IBOutlet weak var controlView: VideoControllView!
    
    
    var foreVideoAsset: AVAsset!
    var backVideoAsset: AVAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let controlScrollPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.controlScrollPanAction(pan:)))
//        self.controlView.addGestureRecognizer(controlScrollPanGesture)
//        self.controlView.isUserInteractionEnabled = true
        
        let foreVideoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/foreVideo.mp4")
        let backVideoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/backVideo.mp4")
        
        self.foreVideoAsset = AVAsset(url: foreVideoURL)
        self.backVideoAsset = AVAsset(url: backVideoURL)
        self.controlView.setupVideo(foreVideo: self.foreVideoAsset, backVideo: self.backVideoAsset)
        self.PlayView.setupVideo(video: self.foreVideoAsset)
    }
    
//    @objc func controlScrollPanAction(pan: UIPanGestureRecognizer) {
//        let trans: CGPoint = pan.translation(in: pan.view)
//        let foreOffset: CGPoint = self.foreScrollView.offset
//        let backOffset: CGPoint = self.backScrollView.offset
//        var deltaOffsetX: CGFloat = 0
//        if trans.x < 0 {
//            deltaOffsetX = -max(trans.x, min(foreOffset.x, backOffset.x) - self.controlScrollView.frame.width * 0.5)
//        } else {
//            deltaOffsetX = -min(trans.x, max(foreOffset.x, backOffset.x) + self.controlScrollView.frame.width * (K_scrollViewWidth - 0.5))
//        }
//        self.foreScrollView.offset = CGPoint(x: foreOffset.x + deltaOffsetX, y: foreOffset.y)
//        self.backScrollView.offset = CGPoint(x: backOffset.x + deltaOffsetX, y: backOffset.y)
//    }
    
    func videoScrollToTime(videoScrollView: VideoScrollView, pos: Float) {
        let duration = self.foreVideoAsset.duration
        let time = CMTime(value: CMTimeValue(pos * Float(duration.value)), timescale: duration.timescale)
        self.PlayView.seek(toTime: time)
    }
    
}
