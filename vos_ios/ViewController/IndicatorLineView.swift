import UIKit

let radius: CGFloat = 5.0
let lineWidth: CGFloat = 1.0

class IndicatorLineView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        let height = self.frame.height
        let width = self.frame.width
                
        let lineView = UIView(frame: CGRect(x: (width - lineWidth) / 2, y: 0, width: lineWidth, height: height))
        lineView.backgroundColor = .red
        self.addSubview(lineView)
        
        let topCircleView = UIView(frame: CGRect(x: width
             / 2 - radius, y: 0, width: 2 * radius, height: 2 * radius))
        topCircleView.backgroundColor = .red
        topCircleView.layer.cornerRadius = radius
        topCircleView.clipsToBounds = true
        self.addSubview(topCircleView)
        
        let bottomCircleView = UIView(frame: CGRect(x: width / 2 - radius, y: height - 2 * radius, width: 2 * radius, height: 2 * radius))
        bottomCircleView.backgroundColor = .red
        bottomCircleView.layer.cornerRadius = radius
        bottomCircleView.clipsToBounds = true
        self.addSubview(bottomCircleView)
    }
    
}
