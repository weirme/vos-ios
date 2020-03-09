import UIKit
import AVKit


class VideoScrollView: UIView {
    
    var scrollView: UIScrollView!
    var slideView: SlideView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        let bounds = self.bounds
        let scrollHeight = bounds.height / 2
        let scrollWidth = bounds.width
        let scrollX = bounds.origin.x
        let scrollY = bounds.midY - scrollHeight / 2
        let scrollRect = CGRect(x: scrollX, y: scrollY, width: scrollWidth, height: scrollHeight)
        
        self.scrollView = UIScrollView(frame: scrollRect)
        self.scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: scrollWidth, bottom: 0, right: scrollWidth)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(self.scrollView)
        
        self.slideView = SlideView(frame: self.scrollView.bounds)
        self.scrollView.addSubview(self.slideView)
    }
    
    func displayVideo(video: AVAsset) {
        let imageGenerator = AVAssetImageGenerator(asset: video)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = CMTime(value: 1, timescale: 100)
        imageGenerator.requestedTimeToleranceAfter = CMTime(value: 1, timescale: 100)
        
        let duration = video.duration
        let startTime = CMTime(value: 0, timescale: duration.timescale)
        let scrollBounds = self.scrollView.bounds
        var frameHeight = CGFloat(0)
        var frameWidth = CGFloat(0)
        var displayHeight = CGFloat(0)
        var displayWidth = CGFloat(0)
        var nFrameDisplay = 0
        
        do {
            let cgimg = try imageGenerator.copyCGImage(at: startTime, actualTime: nil)
            frameHeight = CGFloat(cgimg.height)
            frameWidth = CGFloat(cgimg.width)
        } catch {
            print(error.localizedDescription)
        }
        
        if frameHeight < frameWidth {
            nFrameDisplay = 4
            displayWidth = scrollBounds.size.width / CGFloat(nFrameDisplay)
            displayHeight = scrollBounds.size.height
        } else {
            // todo
        }
        
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
        
        self.scrollView.bringSubviewToFront(self.slideView)
        
    }
    
}
