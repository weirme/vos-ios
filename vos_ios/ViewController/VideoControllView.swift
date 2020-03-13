import UIKit
import AVKit


class VideoControllView: UIView, UIScrollViewDelegate {
    
    var foreScrollView: VideoScrollView!
    var backScrollView: VideoScrollView!
    var timeIndicatorView: IndicatorLineView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    convenience init(frame: CGRect, foreVideo: AVAsset, backVideo: AVAsset) {
        self.init(frame: frame)
        self.setupVideo(foreVideo: foreVideo, backVideo: backVideo)
    }
    
    private func commonInit() {
        self.foreScrollView = VideoScrollView(frame: CGRect(x: 0, y: self.bounds.height * K_videoScrollViewY, width: self.bounds.width, height: self.bounds.height * K_videoScrollViewHeight))
        self.foreScrollView.scrollView.delegate = self
        self.addSubview(self.foreScrollView)

        self.backScrollView = VideoScrollView(frame: CGRect(x: 0, y: self.bounds.height * (1 - K_videoScrollViewY - K_videoScrollViewHeight), width: self.bounds.width, height: self.bounds.height * K_videoScrollViewHeight))
        self.backScrollView.scrollView.delegate = self
        self.addSubview(self.backScrollView)

        self.timeIndicatorView = IndicatorLineView(frame: CGRect(x: self.bounds.width / 2 - indicatorRadius, y: self.bounds.height * K_indicatorViewY, width: 2 * indicatorRadius, height: self.bounds.height * K_indicatorViewHeight))
        self.addSubview(self.timeIndicatorView)
        
    }
    
    func setupVideo(foreVideo: AVAsset, backVideo: AVAsset) {
        let ratio: CGFloat = CGFloat(foreVideo.duration.seconds / backVideo.duration.seconds)
        self.foreScrollView.displayVideo(video: foreVideo, durationRatio: ratio)
        self.backScrollView.displayVideo(video: backVideo, durationRatio: 1 / ratio)
        
        self.foreScrollView.edgeInsets = UIEdgeInsets(top: 0, left: self.backScrollView.contentSize.width, bottom: 0, right: self.backScrollView.contentSize.width)
        self.backScrollView.edgeInsets = UIEdgeInsets(top: 0, left: self.foreScrollView.contentSize.width, bottom: 0, right: self.foreScrollView.contentSize.width)
    }
    
}
