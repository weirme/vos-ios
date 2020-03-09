import UIKit

let slideImageWidth: CGFloat = 50.0
let slideLineHeight: CGFloat = 4.0

class SlideView: UIView {
    
    var startView: UIImageView!
    var endView: UIImageView!
    var topLine: UIView!
    var bottomLine: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit(frame: self.frame)
    }
    
    private func commonInit(frame: CGRect) {
        self.backgroundColor = .clear
        let selfSize = self.bounds.size
        
        self.startView = UIImageView(frame: CGRect(x: 0, y: 0, width: slideImageWidth, height: selfSize.height))
        self.startView.image = UIImage(named: "left")
        self.addSubview(self.startView)
        
        self.endView = UIImageView(frame: CGRect(x: selfSize.width - slideImageWidth, y: 0, width: slideImageWidth, height: selfSize.height))
        self.endView.image = UIImage(named: "right")
        self.addSubview(self.endView)
        
        self.topLine = UIView(frame: CGRect(x: 0, y: 0, width: selfSize.width, height: slideLineHeight))
        self.topLine.backgroundColor = .white
        self.addSubview(self.topLine)
        
        self.bottomLine =  UIView(frame: CGRect(x: 0, y: selfSize.height - slideLineHeight, width: selfSize.width, height: slideLineHeight))
        self.bottomLine.backgroundColor = .white
        self.addSubview(self.bottomLine)
    
    }
}
