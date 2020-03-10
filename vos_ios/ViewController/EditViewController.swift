import UIKit
import AVKit
import ImageScrollView


class EditViewController: UIViewController {
    
    @IBOutlet weak var PlayView: ImageScrollView!
    @IBOutlet weak var controlScrollView: UIView!
    @IBOutlet weak var foreScrollView: VideoScrollView!
    @IBOutlet weak var backScrollView: VideoScrollView!
    
    var foreVideoAsset: AVAsset!
    var backVideoAsset: AVAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(pan:)))
        self.controlScrollView.addGestureRecognizer(panGesture)
        self.controlScrollView.isUserInteractionEnabled = true
        
        let videoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/video.mp4")
        self.foreVideoAsset = AVAsset(url: videoURL)
        self.foreScrollView.displayVideo(video: self.foreVideoAsset)
        self.backVideoAsset = AVAsset(url: videoURL)
        self.backScrollView.displayVideo(video: self.backVideoAsset)
        
    }
    
    @objc func panAction(pan: UIPanGestureRecognizer) {
        let trans: CGPoint = pan.translation(in: self.controlScrollView)
        let foreOffset: CGPoint = self.foreScrollView.scrollView.contentOffset
        let backOffset: CGPoint = self.backScrollView.scrollView.contentOffset
        var deltaOffsetX: CGFloat = 0
        if trans.x < 0 {
            deltaOffsetX = -min(foreOffset.x, backOffset.x)
        } else {
            deltaOffsetX = -max(foreOffset.x, backOffset.x)
        }
        self.foreScrollView.scrollView.setContentOffset(CGPoint(x: foreOffset.x + deltaOffsetX, y: foreOffset.y), animated: true)
        self.backScrollView.scrollView.setContentOffset(CGPoint(x: backOffset.x + deltaOffsetX, y: backOffset.y), animated: true)
        
    }
    
}
