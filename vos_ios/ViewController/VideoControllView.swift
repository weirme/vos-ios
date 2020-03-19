import UIKit
import AVKit


protocol VideoControlDelegate {
    func videoScrollToTime(pos: Float, forVideo: WhichVideo)
}


fileprivate enum ScrollIndicatorPosState {
    case out
    case `in`
}


class VideoControllView: UIView, UIScrollViewDelegate, SlideViewProtocol {
    
    var foreScrollView: VideoScrollView!
    var backScrollView: VideoScrollView!
    var timeIndicatorView: IndicatorLineView!
    private var panGestureScrollAll: UIPanGestureRecognizer!
    
    var delegate: VideoControlDelegate?
    
    var indicatorMidX: CGFloat {
        return self.timeIndicatorView.frame.midX
    }
    
    private var foreIndicatorPosState: ScrollIndicatorPosState = .out {
        willSet {
            let state: Bool = (newValue == .out)
            let name = Notification.Name("ForeIndicatorAlignedNotification")
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["state": state])
        }
    }
    
    var foreClipStartPos: Float {
        return Float(self.foreScrollView.clipStartPos)
    }
    
    var foreClipEndPos: Float {
        return Float(self.foreScrollView.clipEndPos)
    }
    
    var backClipStartPos: Float {
        return Float(self.backScrollView.clipStartPos)
    }
    
    var backClipEndPos: Float {
        return Float(self.backScrollView.clipEndPos)
    }
    
    var foreReadyToPlay: Bool {
        return self.foreScrollView.clipStart <= self.indicatorMidX
    }
    
    var backReadyToPlay: Bool {
        return self.backScrollView.clipStart <= self.indicatorMidX
    }
    
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
        self.addSubview(self.timeIndicatorView)
                
        self.panGestureScrollAll = UIPanGestureRecognizer(target: self, action: #selector(self.panActionScrollAll(pan:)))
        self.addGestureRecognizer(self.panGestureScrollAll)
        
    }
    
    func setupVideo(foreVideo: AVAsset, backVideo: AVAsset) {
        let ratio: CGFloat = CGFloat(foreVideo.duration.seconds / backVideo.duration.seconds)
        self.foreScrollView.displayVideo(video: foreVideo, durationRatio: ratio)
        self.backScrollView.displayVideo(video: backVideo, durationRatio: 1 / ratio)
        
        self.foreScrollView.slideView.delegate = self
        self.backScrollView.slideView.delegate = self
        
        self.foreScrollView.edgeInsets = UIEdgeInsets(top: 0, left: self.backScrollView.contentSize.width / 2, bottom: 0, right: self.backScrollView.contentSize.width / 2)
        self.backScrollView.edgeInsets = UIEdgeInsets(top: 0, left: self.foreScrollView.contentSize.width, bottom: 0, right: self.foreScrollView.contentSize.width)
    }
    
    @objc func tapAction(tap: UITapGestureRecognizer) {
        let view = tap.view as! VideoScrollView
        let anotherView = (view == self.foreScrollView ? self.backScrollView : self.foreScrollView)!
        view.isSelected = !view.isSelected
        if view.isSelected {
            anotherView.isSelected = false
        }
        self.panGestureScrollAll.isEnabled = !self.foreScrollView.isSelected && !self.backScrollView.isSelected
    }
    
    @objc func panActionScrollAll(pan: UIPanGestureRecognizer) {
        let trans: CGPoint = pan.translation(in: pan.view)
        let foreOffset: CGPoint = self.foreScrollView.offset
        let backOffset: CGPoint = self.backScrollView.offset
        let leftX: CGFloat = max(foreOffset.x, backOffset.x)
        let rightX: CGFloat = min(foreOffset.x - self.foreScrollView.contentSize.width, backOffset.x - self.backScrollView.contentSize.width)
        
        var deltaOffsetX: CGFloat = 0
        if trans.x < 0 {
            deltaOffsetX = -max(trans.x, rightX + scrollViewWidth + scrollViewStandardOffset)
        } else {
            deltaOffsetX = -min(trans.x, leftX - scrollViewStandardOffset)
        }
        self.foreScrollView.offset = CGPoint(x: foreOffset.x + deltaOffsetX, y: foreOffset.y)
        self.backScrollView.offset = CGPoint(x: backOffset.x + deltaOffsetX, y: backOffset.y)
    }
    
    private func updateForeIndicatorPosState() {
        if self.foreIndicatorPosState == .out && self.foreScrollView.clipStart < self.indicatorMidX && self.indicatorMidX < self.foreScrollView.clipEnd {
            self.foreIndicatorPosState = .in
        } else if self.foreIndicatorPosState == .in && (self.foreScrollView.clipStart > self.indicatorMidX || self.indicatorMidX > self.foreScrollView.clipEnd) {
            self.foreIndicatorPosState = .out
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let trans: CGPoint = scrollView.contentOffset
        let pos = (self.indicatorMidX - scrollViewX + trans.x) / scrollView.contentSize.width
        let view = scrollView.superview as! VideoScrollView
        let forVideo: WhichVideo = view == self.foreScrollView ? .fore : .back
        self.delegate?.videoScrollToTime(pos: Float(pos), forVideo: forVideo)
        if forVideo == .fore {
            self.updateForeIndicatorPosState()
        }
    }
    
    func didSlide() {
        self.updateForeIndicatorPosState()
    }
    
    func scrollToPos(pos: Float, forVideo: WhichVideo) {
        let videoScrollView: VideoScrollView = forVideo == .fore ? self.foreScrollView : self.backScrollView
        let offsetX: CGFloat = CGFloat(pos) * videoScrollView.contentSize.width - (self.indicatorMidX - scrollViewX)
        let dx = offsetX - videoScrollView.offset.x
        self.foreScrollView.scrollView.setContentOffset(CGPoint(x: self.foreScrollView.offset.x + dx, y: self.foreScrollView.offset.y), animated: false)
        self.backScrollView.scrollView.setContentOffset(CGPoint(x: self.backScrollView.offset.x + dx, y: self.backScrollView.offset.y), animated: false)
    }
    
    func resetScrollViewOffset() {
        let dx = self.backScrollView.clipStart - self.indicatorMidX
        let foreOffset = self.foreScrollView.offset
        let backOffset = self.backScrollView.offset
        if dx > 0 {
            self.foreScrollView.offset = CGPoint(x: foreOffset.x + dx, y: foreOffset.y)
            self.backScrollView.offset = CGPoint(x: backOffset.x + dx, y: backOffset.y)
        }
    }
    
}
