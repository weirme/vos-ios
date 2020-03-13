import UIKit
import AVKit


protocol VideoScrollDelegate {
    func videoScrollToTime(videoScrollView: VideoScrollView, pos: Float)
}


class VideoScrollView: UIView, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var slideView: SlideView!
    var selectButton: UIButton!
    
    var delegate: VideoScrollDelegate?
    
    var contentSize: CGSize {
        get {
            return self.scrollView.contentSize
        }
        set {
            self.scrollView.contentSize = newValue
        }
    }
    
    var offset: CGPoint {
        get {
            return self.scrollView.contentOffset
        }
        set {
            self.scrollView.setContentOffset(newValue, animated: true)
        }
    }
    
    var edgeInsets: UIEdgeInsets {
        get {
            return self.scrollView.contentInset
        }
        set {
            self.scrollView.contentInset = newValue
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
        let scrollHeight = self.bounds.height * 0.8
        let scrollWidth = self.bounds.width * 0.75
        let scrollX = self.bounds.width * 0.2
        let scrollY = self.bounds.midY - scrollHeight / 2
        let scrollRect = CGRect(x: scrollX, y: scrollY, width: scrollWidth, height: scrollHeight)
        self.scrollView = UIScrollView(frame: scrollRect)
        self.scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: scrollWidth, bottom: 0, right: scrollWidth)
        self.scrollView.contentOffset = CGPoint(x: -screenWidth * 0.3, y: 0)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.layer.cornerRadius = 5
        self.scrollView.backgroundColor = #colorLiteral(red: 0.1139808074, green: 0.1214027479, blue: 0.1340248883, alpha: 1)
        self.addSubview(self.scrollView)
        
        let buttonRadius = CGFloat(10.0)
        self.selectButton = UIButton(frame: CGRect(x: self.bounds.width * 0.1 - buttonRadius, y: self.bounds.midY - buttonRadius, width: buttonRadius * 2, height: buttonRadius * 2))
        self.selectButton.setImage(UIImage(systemName: "circle"), for: .normal)
        self.addSubview(self.selectButton)
        
        self.backgroundColor = #colorLiteral(red: 0.16138798, green: 0.164371103, blue: 0.1895281374, alpha: 1)
    }
    
    func displayVideo(video: AVAsset, durationRatio: CGFloat) {
        let duration = video.duration
        let track = video.tracks.first!
        let resolution = track.naturalSize.applying(track.preferredTransform)
        var contentWidth = self.scrollView.bounds.width * 0.7
        var imgHeight = CGFloat(0)
        var imgWidth = CGFloat(0)
        var nImgDisplay = 0
        
        if resolution.height < resolution.width {
            if durationRatio <= 1 {
                nImgDisplay = N_imgDefault
            } else {
                nImgDisplay = Int(CGFloat(N_imgDefault) * durationRatio)
                contentWidth *= durationRatio
            }
            self.scrollView.contentSize.width = contentWidth
            imgWidth = contentWidth / CGFloat(nImgDisplay)
            imgHeight = self.scrollView.bounds.height
        } else {
            // todo
        }
        
        let imageGenerator = AVAssetImageGenerator(asset: video)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = timeTolerance
        imageGenerator.requestedTimeToleranceAfter = timeTolerance
        let increment = duration.value / Int64(nImgDisplay)
        for i in 0..<nImgDisplay {
            let t = CMTime(value: Int64(i) * increment, timescale: duration.timescale)
            do {
                let cgimg = try imageGenerator.copyCGImage(at: t, actualTime: nil)
                let rect = CGRect(x: CGFloat(i) * imgWidth, y: slideLineHeight, width: imgWidth, height: imgHeight - 2 * slideLineHeight)
                let imgView = UIImageView(frame: rect)
                imgView.image = UIImage(cgImage: cgimg)
                self.scrollView.addSubview(imgView)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        self.slideView = SlideView(frame: CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height))
        self.scrollView.addSubview(self.slideView)
        self.scrollView.bringSubviewToFront(self.slideView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let trans: CGPoint = scrollView.contentOffset
        let pos = (self.frame.midX - scrollView.frame.origin.x + trans.x) / scrollView.frame.width
//        self.delegate?.videoScrollToTime(videoScrollView: self, pos: Float(pos))
    }
    
}
