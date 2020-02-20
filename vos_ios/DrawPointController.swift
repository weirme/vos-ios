import UIKit
import NVActivityIndicatorView

let buttonWidth: CGFloat = 50.0
let buttonHeight: CGFloat = 30.0
let buttonPad: CGFloat = 10.0


class DrawPointController: UIViewController, NVActivityIndicatorViewable {
    
    var undoButton: UIButton!
    var okButton: UIButton!
    
    var imageView: UIImageView!
    var image: UIImage!

    var coords: [[Int]] = []
    var xmarks: [UIImageView] = []
    var isOverlay = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.addButtons()
        self.initImageView()
    }
    
    func initImageView() {
        let frame: CGRect = getImageViewFrame(image: self.image)
        self.imageView = UIImageView(frame: frame)
        self.imageView.image = self.image
        self.view.addSubview(self.imageView)
        
        self.imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(tap:)))
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    func addButtons() {
        let screenSize = UIScreen.main.bounds.size
        
        self.undoButton = UIButton(frame: CGRect(x: buttonPad, y: buttonPad, width: buttonWidth, height: buttonHeight))
        self.undoButton.setTitle("Undo", for: .normal)
        self.undoButton.setTitleColor(.red, for: .normal)
        self.undoButton.contentHorizontalAlignment = .leading
        self.undoButton.addTarget(self, action: #selector(undoAction(sender:)), for: .touchUpInside)
        
        self.okButton = UIButton(frame: CGRect(x: screenSize.width - buttonPad - buttonWidth, y: buttonPad, width: buttonWidth, height: buttonHeight))
        self.okButton.setTitle("OK", for: .normal)
        self.okButton.setTitleColor(.blue, for: .normal)
        self.okButton.contentHorizontalAlignment = .trailing
        self.okButton.addTarget(self, action: #selector(okAction(sender:)), for: .touchUpInside)
        self.okButton.isHidden = true
        
        self.view.addSubview(self.undoButton)
        self.view.addSubview(self.okButton)
    }
    
    @objc func tapAction(tap: UITapGestureRecognizer) {
        let point = tap.location(in: self.imageView)
        let config =  UIImage.SymbolConfiguration(pointSize: 8, weight: .black)
        let xmark = UIImageView(image: UIImage(systemName: "xmark", withConfiguration: config))
        xmark.frame.origin = CGPoint(
            x: point.x - xmark.frame.size.width / 2,
            y: point.y - xmark.frame.size.height / 2)
        xmark.tintColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
        
        self.coords.append(
        getCoordsInImage(coordsInView: point, imgSize: self.image.size, viewSize: self.imageView.bounds.size))
        self.xmarks.append(xmark)
        self.imageView.addSubview(xmark)
        
        if self.coords.count == 4 {
            self.imageView.isUserInteractionEnabled = false
            self.okButton.isHidden = false
        }
    }
    
    @objc func undoAction(sender: UIButton) {
        if self.isOverlay {
            self.imageView.image = self.image
            self.isOverlay = false
        } else {
            if self.coords.count == 0 {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.coords.popLast()
                let xmark = self.xmarks.popLast()
                xmark?.removeFromSuperview()
                self.imageView.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc func okAction(sender: UIButton) {
        startAnimating(CGSize(width: 80, height: 80), message: "Processing...", type: NVActivityIndicatorType.pacman, color: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), backgroundColor: UIColor(displayP3Red: 128, green: 128, blue: 128, alpha: 0.3), textColor: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))
        DispatchQueue.global().async {
            let overlayImg: UIImage! = CVHelper.makeOverlayMask(image: self.image, coords: self.coords)
            DispatchQueue.main.async {
                self.stopAnimating()
                self.okButton.isHidden = true
                self.coords.removeAll()
                for xmark in self.xmarks {
                    xmark.removeFromSuperview()
                }
                self.xmarks.removeAll()
                self.imageView.image = overlayImg
                self.isOverlay = true
            }
        }
    }
    
}


func getImageViewFrame(image: UIImage) -> CGRect {
    let imSize = image.size
    let screenSize = UIScreen.main.bounds.size
    let vheight: CGFloat
    let vwidth: CGFloat
    
    if imSize.height < imSize.width {
        vheight = imSize.height * screenSize.width / imSize.width
        vwidth = screenSize.width
    } else {
        vheight = screenSize.height - buttonHeight - 2 * buttonPad
        vwidth = imSize.width * screenSize.height / imSize.height
    }
    
    let origin: CGPoint
    if imSize.height < imSize.width {
        origin = CGPoint(x: 0, y: (screenSize.height - vheight) / 2)
    } else {
        origin = CGPoint(x: 0, y: buttonHeight + 2 * buttonPad)
    }
    
    let frame = CGRect(origin: origin, size: CGSize(width: vwidth, height: vheight))
    return frame
}


func getCoordsInImage(coordsInView: CGPoint, imgSize: CGSize, viewSize: CGSize) -> Array<Int> {
    let x = coordsInView.x * imgSize.width / viewSize.width
    let y = coordsInView.y * imgSize.height / viewSize.height
    return [Int(x), Int(y)]
}
