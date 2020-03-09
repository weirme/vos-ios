import UIKit
import AVKit


class VideoScrollView: UIView {
    
    var scrollView: UIScrollView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        let bounds = self.bounds
        self.scrollView = UIScrollView(frame: CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: bounds.height)))
        self.addSubview(self.scrollView)
    }
    
    func displayVideo(video: AVAsset) {
        let imageGenerator = AVAssetImageGenerator(asset: video)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = CMTime(value: 1, timescale: 100)
        imageGenerator.requestedTimeToleranceAfter = CMTime(value: 1, timescale: 100)
        
        let duration = video.duration
        let startTime = CMTime(value: 0, timescale: duration.timescale)
        let bounds = self.scrollView.bounds
        var frameHeight = CGFloat(0)
        var frameWidth = CGFloat(0)
        var displayHeight = CGFloat(0)
        var displayWidth = CGFloat(0)
        var originy = CGFloat(0)
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
            displayWidth = bounds.size.width / CGFloat(nFrameDisplay)
            displayHeight = bounds.size.height / 2
            originy = (bounds.height - displayHeight) / 2
        } else {
            // todo
        }
        
        let increment = duration.value / Int64(nFrameDisplay)
        for i in 0..<nFrameDisplay {
            let t = CMTime(value: Int64(i) * increment, timescale: duration.timescale)
            do {
                let cgimg = try imageGenerator.copyCGImage(at: t, actualTime: nil)
                let rect = CGRect(x: CGFloat(i) * displayWidth, y: originy, width: displayWidth, height: displayHeight)
                let imgView = UIImageView(frame: rect)
                imgView.image = UIImage(cgImage: cgimg)
                self.scrollView.addSubview(imgView)
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
}
