import UIKit
import AVKit


protocol VideoControlDelegate {
    func videoSeekToTime(pos: Float)
}


class VideoControllView: UIView, UIScrollViewDelegate {
    
    var foreScrollView: VideoScrollView!
    var backScrollView: VideoScrollView!
    var timeIndicatorView: IndicatorLineView!
    private var panGestureScrollAll: UIPanGestureRecognizer!
    
    var delegate: VideoControlDelegate?
    
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
        let foreTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(tap:)))
        self.foreScrollView.addGestureRecognizer(foreTapGesture)
        self.addSubview(self.foreScrollView)

        self.backScrollView = VideoScrollView(frame: CGRect(x: 0, y: self.bounds.height * (1 - K_videoScrollViewY - K_videoScrollViewHeight), width: self.bounds.width, height: self.bounds.height * K_videoScrollViewHeight))
        self.backScrollView.scrollView.delegate = self
        let backTapGesture =  UITapGestureRecognizer(target: self, action: #selector(self.tapAction(tap:)))
        self.backScrollView.addGestureRecognizer(backTapGesture)
        self.addSubview(self.backScrollView)

        self.timeIndicatorView = IndicatorLineView(frame: CGRect(x: self.bounds.width * K_indicatorViewMidX - indicatorRadius, y: self.bounds.height * K_indicatorViewY, width: 2 * indicatorRadius, height: self.bounds.height * K_indicatorViewHeight))
        let panGestureMoveIndicator = UIPanGestureRecognizer(target: self, action: #selector(self.panActionMoveIndicator(pan:)))
        self.timeIndicatorView.addGestureRecognizer(panGestureMoveIndicator)
        self.addSubview(self.timeIndicatorView)
                
        self.panGestureScrollAll = UIPanGestureRecognizer(target: self, action: #selector(self.panActionScrollAll(pan:)))
        self.addGestureRecognizer(self.panGestureScrollAll)
        
    }
    
    func setupVideo(foreVideo: AVAsset, backVideo: AVAsset) {
        let ratio: CGFloat = CGFloat(foreVideo.duration.seconds / backVideo.duration.seconds)
        self.foreScrollView.displayVideo(video: foreVideo, durationRatio: ratio)
        self.backScrollView.displayVideo(video: backVideo, durationRatio: 1 / ratio)
        
        self.foreScrollView.edgeInsets = UIEdgeInsets(top: 0, left: self.backScrollView.contentSize.width / 2, bottom: 0, right: self.backScrollView.contentSize.width / 2)
        self.backScrollView.edgeInsets = UIEdgeInsets(top: 0, left: self.foreScrollView.contentSize.width / 2, bottom: 0, right: self.foreScrollView.contentSize.width / 2)
    }
    
    @objc func tapAction(tap: UITapGestureRecognizer) {
        let view = tap.view as! VideoScrollView
        let anotherView = (view == self.foreScrollView ? self.backScrollView : self.foreScrollView)!
        view.isScrollEnabled = !view.isScrollEnabled
        if view.isScrollEnabled {
            anotherView.isScrollEnabled = false
            let deltaOffsetX: CGFloat = view.offset.x + scrollViewStandardOffset
            view.offset = CGPoint(x: -scrollViewStandardOffset, y: 0)
            anotherView.offset = CGPoint(x: anotherView.offset.x - deltaOffsetX, y: 0)
        }
        self.panGestureScrollAll.isEnabled = !self.foreScrollView.isScrollEnabled && !self.backScrollView.isScrollEnabled
    }
    
    @objc func panActionScrollAll(pan: UIPanGestureRecognizer) {
        let trans: CGPoint = pan.translation(in: pan.view)
        let foreOffset: CGPoint = self.foreScrollView.offset
        let backOffset: CGPoint = self.backScrollView.offset
        let leftX: CGFloat = max(foreOffset.x, backOffset.x)
        let rightX: CGFloat = min(foreOffset.x - self.foreScrollView.contentSize.width, backOffset.x - self.backScrollView.contentSize.width)
        
        var deltaOffsetX: CGFloat = 0
        if trans.x < 0 {
            deltaOffsetX = -max(trans.x, rightX + screenWidth * K_scrollViewWidth)
        } else {
            deltaOffsetX = -min(trans.x, leftX)
        }
        self.foreScrollView.offset = CGPoint(x: foreOffset.x + deltaOffsetX, y: foreOffset.y)
        self.backScrollView.offset = CGPoint(x: backOffset.x + deltaOffsetX, y: backOffset.y)
    }
    
    @objc func panActionMoveIndicator(pan: UIPanGestureRecognizer) {
        let view = pan.view!
        let trans: CGPoint = pan.translation(in: view)
        let curX = view.frame.midX
        if curX + trans.x >= scrollViewX && curX + trans.x <= scrollViewX + scrollViewWidth {
            view.frame = view.frame.offsetBy(dx: trans.x, dy: 0)
        }
        let pos = (self.timeIndicatorView.frame.midX -  self.foreScrollView.scrollView.frame.origin.x + trans.x) / self.foreScrollView.contentSize.width
        self.delegate?.videoSeekToTime(pos: Float(pos))
        pan.setTranslation(CGPoint.zero, in: view)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let trans: CGPoint = self.foreScrollView.offset
        let pos = (self.timeIndicatorView.frame.midX -  self.foreScrollView.scrollView.frame.origin.x + trans.x) / self.foreScrollView.contentSize.width
        self.delegate?.videoSeekToTime(pos: Float(pos))
    }
    
}
