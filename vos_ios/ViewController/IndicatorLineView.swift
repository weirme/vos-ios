import UIKit


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
                
        let lineView = UIView(frame: CGRect(x: (width - indicatorLineWidth) / 2, y: 0, width: indicatorLineWidth, height: height))
        lineView.backgroundColor = .red
        self.addSubview(lineView)
        
        let topCircleView = UIView(frame: CGRect(x: width
             / 2 - indicatorRadius, y: 0, width: 2 * indicatorRadius, height: 2 * indicatorRadius))
        topCircleView.backgroundColor = .red
        topCircleView.layer.cornerRadius = indicatorRadius
        topCircleView.clipsToBounds = true
        self.addSubview(topCircleView)
        
        let bottomCircleView = UIView(frame: CGRect(x: width / 2 - indicatorRadius, y: height - 2 * indicatorRadius, width: 2 * indicatorRadius, height: 2 * indicatorRadius))
        bottomCircleView.backgroundColor = .red
        bottomCircleView.layer.cornerRadius = indicatorRadius
        bottomCircleView.clipsToBounds = true
        self.addSubview(bottomCircleView)
    }
    
}
