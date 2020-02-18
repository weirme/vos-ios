import UIKit

class DrawPointController: UIViewController {
    
    var imageView: UIImageView!
    var image: UIImage!
    
    var coordinateList: [CGPoint] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.initImageView()
    }
    
    func initImageView() {
        let fullScreenSize = UIScreen.main.bounds.size
        
        self.image = image.resizeByLonger(screenSize: fullScreenSize)
        let size = self.image.size
        let origin: CGPoint
        if size.height < size.width {
            origin = CGPoint(x: 0, y: (fullScreenSize.height - size.height) / 2)
        } else {
            origin = CGPoint(x: 0, y: 0)
        }
        self.imageView = UIImageView(frame: CGRect(origin: origin, size: size))
        self.imageView.image = self.image
        self.view.addSubview(self.imageView)
        
        self.imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(tap:)))
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapAction(tap: UITapGestureRecognizer) {
        let point = tap.location(in: self.imageView)
        print(point.x, point.y)
        self.coordinateList.append(point)
        let config =  UIImage.SymbolConfiguration(pointSize: 8, weight: .black)
        let img = UIImageView(image: UIImage(systemName: "xmark", withConfiguration: config))
        img.frame.origin = CGPoint(x: point.x, y: point.y)
        img.tintColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
        self.imageView.addSubview(img)
        
        if self.coordinateList.count == 4 {
            self.imageView.isUserInteractionEnabled = false
        }
    }
}

extension UIImage {
    func resizeByLonger(screenSize: CGSize) -> UIImage {
        let height = self.size.height
        let width = self.size.width
        let toheight: CGFloat
        let towidth: CGFloat
        
        if height < width {
            toheight =  height * screenSize.width / width
            towidth = screenSize.width
        } else {
            toheight = screenSize.height
            towidth = width * screenSize.height / height
        }
        
        let tosize = CGSize(width: towidth, height: toheight)
        UIGraphicsBeginImageContextWithOptions(tosize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: towidth, height: toheight))
        let toimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return toimage!
    }
}
