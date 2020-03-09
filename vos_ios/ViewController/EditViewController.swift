import UIKit
import AVKit
import ImageScrollView


class EditViewController: UIViewController {
    
    @IBOutlet weak var PlayView: ImageScrollView!
    @IBOutlet weak var foreScrollView: VideoScrollView!
    @IBOutlet weak var backScrollView: VideoScrollView!
    
    var foreVideoAsset: AVAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let videoURL = URL(fileURLWithPath: "/Users/sameal/Documents/PROJECT/vos_ios/vos_ios/video.mp4")
        self.foreVideoAsset = AVAsset(url: videoURL)
        self.foreScrollView.displayVideo(video: self.foreVideoAsset)
    }
    
}
