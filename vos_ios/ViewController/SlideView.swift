import UIKit

let slideImageWidth: CGFloat = 15.0
let slideLineHeight: CGFloat = 4.0
let leftTag: Int = 1
let rightTag: Int = 2

class SlideView: UIView {
    
    var startView: UIImageView!
    var endView: UIImageView!
    var topLineView: UIView!
    var bottomLineView: UIView!
    var leftShadowView: UIView!
    var rightShadowView: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        let selfSize = self.bounds.size
        
        self.startView = UIImageView(frame: CGRect(x: 0, y: 0, width: slideImageWidth, height: selfSize.height))
        self.startView.image = UIImage(named: "left")
        self.startView.tag = leftTag
        let leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(pan:)))
        leftPanGesture.maximumNumberOfTouches = 1
        leftPanGesture.minimumNumberOfTouches = 1
        self.startView.addGestureRecognizer(leftPanGesture)
        self.startView.isUserInteractionEnabled = true
        self.addSubview(self.startView)
        
        self.endView = UIImageView(frame: CGRect(x: selfSize.width - slideImageWidth, y: 0, width: slideImageWidth, height: selfSize.height))
        self.endView.image = UIImage(named: "right")
        self.endView.tag = rightTag
        let rightPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(pan:)))
        rightPanGesture.maximumNumberOfTouches = 1
        rightPanGesture.minimumNumberOfTouches = 1
        self.endView.addGestureRecognizer(rightPanGesture)
        self.endView.isUserInteractionEnabled = true
        self.addSubview(self.endView)
        
        self.topLineView = UIView(frame: CGRect(x: 0, y: 0, width: selfSize.width, height: slideLineHeight))
        self.topLineView.backgroundColor = .white
        self.addSubview(self.topLineView)
        
        self.bottomLineView =  UIView(frame: CGRect(x: 0, y: selfSize.height - slideLineHeight, width: selfSize.width, height: slideLineHeight))
        self.bottomLineView.backgroundColor = .white
        self.addSubview(self.bottomLineView)
        
        self.leftShadowView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: selfSize.height))
        self.leftShadowView.backgroundColor = .black
        self.leftShadowView.alpha = 0.8
        self.addSubview(self.leftShadowView)
        
        self.rightShadowView = UIView(frame: CGRect(x: selfSize.width, y: 0, width: 0, height: selfSize.height))
        self.rightShadowView.backgroundColor = .black
        self.rightShadowView.alpha = 0.8
        self.addSubview(self.rightShadowView)
    
    }
    
    @objc func panAction(pan: UIPanGestureRecognizer) {
        let view: UIView = pan.view!
        let superview: UIView = view.superview!
        let origin: CGPoint = view.frame.origin
        let trans: CGPoint = pan.translation(in: view)
        
        if view.tag == leftTag {
            if origin.x + trans.x >= 0 && origin.x + trans.x + slideImageWidth <= self.endView.frame.minX {
                view.frame = view.frame.offsetBy(dx: trans.x, dy: 0)
                self.leftShadowView.frame = CGRect(x: 0, y: 0, width: view.frame.minX, height: view.frame.height)
            }
        } else if view.tag == rightTag {
            if origin.x + trans.x >= self.startView.frame.maxX && origin.x + trans.x + slideImageWidth <= superview.frame.maxX {
                view.frame = view.frame.offsetBy(dx: trans.x, dy: 0)
                self.rightShadowView.frame = CGRect(x: view.frame.maxX, y: 0, width: superview.frame.maxX - view.frame.maxX, height: view.frame.height)
            }
        }
        
        self.topLineView.frame = CGRect(x: self.startView.frame.origin.x, y: 0, width: self.endView.frame.maxX - self.startView.frame.minX, height: slideLineHeight)
        self.bottomLineView.frame = CGRect(x: self.startView.frame.origin.x, y: superview.frame.height - slideLineHeight, width: self.endView.frame.maxX - self.startView.frame.minX, height: slideLineHeight)
        
        pan.setTranslation(CGPoint.zero, in: view)
    }
}
