import UIKit
import AVKit


protocol VideoScrollDelegate {
    func videoScrollToTime(videoScrollView: VideoScrollView, pos: Float)
}


class VideoScrollView: UIView, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var slideView: SlideView!
    
    var delegate: VideoScrollDelegate?
    var offset: CGPoint {
        get {
            return self.scrollView.contentOffset
        }
        set {
            self.scrollView.setContentOffset(newValue, animated: true)
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        let scrollHeight = self.bounds.height * 0.7
        let scrollWidth = self.bounds.width * 0.8
        let scrollX = self.bounds.width * 0.2
        let scrollY = self.bounds.midY - scrollHeight / 2
        let scrollRect = CGRect(x: scrollX, y: scrollY, width: scrollWidth, height: scrollHeight)
        
        self.scrollView = UIScrollView(frame: scrollRect)
        self.scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: scrollWidth, bottom: 0, right: scrollWidth)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.delegate = self
        self.addSubview(self.scrollView)
        
        self.slideView = SlideView(frame: self.scrollView.bounds)
    }
        
    func displayVideo(video: AVAsset) {
        let scrollBounds = self.scrollView.bounds
        let duration = video.duration
        let track = video.tracks.first!
        let resolution = track.naturalSize.applying(track.preferredTransform)
        var displayHeight = CGFloat(0)
        var displayWidth = CGFloat(0)
        var nFrameDisplay = 0
        
        if resolution.height < resolution.width {
            nFrameDisplay = 4
            displayWidth = scrollBounds.size.width / CGFloat(nFrameDisplay)
            displayHeight = scrollBounds.size.height
        } else {
            // todo
        }
        
        let imageGenerator = AVAssetImageGenerator(asset: video)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = CMTime(value: 1, timescale: 15)
        imageGenerator.requestedTimeToleranceAfter = CMTime(value: 1, timescale: 15)
        let increment = duration.value / Int64(nFrameDisplay)
        for i in 0..<nFrameDisplay {
            let t = CMTime(value: Int64(i) * increment, timescale: duration.timescale)
            do {
                let cgimg = try imageGenerator.copyCGImage(at: t, actualTime: nil)
                let rect = CGRect(x: CGFloat(i) * displayWidth, y: 0, width: displayWidth, height: displayHeight)
                let imgView = UIImageView(frame: rect)
                imgView.image = UIImage(cgImage: cgimg)
                self.scrollView.addSubview(imgView)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        self.scrollView.addSubview(self.slideView)
        self.scrollView.bringSubviewToFront(self.slideView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let trans: CGPoint = scrollView.contentOffset
        let pos = (self.frame.midX - scrollView.frame.origin.x + trans.x) / scrollView.frame.width
        self.delegate?.videoScrollToTime(videoScrollView: self, pos: Float(pos))
    }
    
}
