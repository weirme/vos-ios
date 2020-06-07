import UIKit
import NVActivityIndicatorView
import ImageScrollView


class DrawPointViewController: UIViewController, NVActivityIndicatorViewable {
    
    var undoButton: UIButton!
    var okButton: UIButton!
    var scrollView: ImageScrollView!
    var tapGesture: UITapGestureRecognizer!
    var image: UIImage!

    var videoURL: URL!
    var maskURL: URL? = nil
        
    var coords: [[Int]] = []
    var xmarks: [UIImageView] = []
    var isOverlay = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.addButtons()
        self.initScrollView()
    }
    
    // MARK: - Init view
    
    func initScrollView() {
        let frame: CGRect = CGRect(x: 0, y: 2 * buttonPad + buttonHeight, width: screenWidth, height: screenHeight - 2 * buttonPad - buttonHeight)
        self.scrollView = ImageScrollView(frame: frame)
        self.scrollView.setup()
        self.scrollView.imageContentMode = .aspectFit
        self.scrollView.initialOffset = .center
        self.scrollView.display(image: self.image)
        self.view.addSubview(self.scrollView)
        
        self.scrollView.isUserInteractionEnabled = true
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(tap:)))
        self.scrollView.zoomView?.addGestureRecognizer(tapGesture)
    }
    
    func addButtons() {
        let screenSize = UIScreen.main.bounds.size
        
        self.undoButton = UIButton(frame: CGRect(x: buttonPad, y: buttonPad, width: buttonWidth, height: buttonHeight))
        self.undoButton.setTitle("Undo", for: .normal)
        self.undoButton.setTitleColor(.red, for: .normal)
        self.undoButton.contentHorizontalAlignment = .leading
        self.undoButton.addTarget(self, action: #selector(self.undoAction(sender:)), for: .touchUpInside)
        
        self.okButton = UIButton(frame: CGRect(x: screenSize.width - buttonPad - buttonWidth, y: buttonPad, width: buttonWidth, height: buttonHeight))
        self.okButton.setTitle("OK", for: .normal)
        self.okButton.setTitleColor(.blue, for: .normal)
        self.okButton.contentHorizontalAlignment = .trailing
        self.okButton.addTarget(self, action: #selector(self.okAction(sender:)), for: .touchUpInside)
        self.okButton.isHidden = true
        
        self.view.addSubview(self.undoButton)
        self.view.addSubview(self.okButton)
    }
    
    // MARK: - Event actions
    
    @objc func tapAction(tap: UITapGestureRecognizer) {
        let point = tap.location(in: self.scrollView.zoomView)
        let config =  UIImage.SymbolConfiguration(pointSize: self.image.size.width / 50, weight: .black)
        let xmark = UIImageView(image: UIImage(systemName: "xmark", withConfiguration: config))
        xmark.frame.origin = CGPoint(
            x: point.x - xmark.frame.size.width / 2,
            y: point.y - xmark.frame.size.height / 2)
        xmark.tintColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
        
        self.coords.append([Int(point.x), Int(point.y)])
        self.xmarks.append(xmark)
        self.scrollView.zoomView?.addSubview(xmark)
        
        if self.coords.count == 4 {
            self.tapGesture.isEnabled = false
            self.okButton.isHidden = false
        }
    }
    
    @objc func undoAction(sender: UIButton) {
        if self.isOverlay {
            self.scrollView.display(image: self.image)
            self.scrollView.zoomView?.addGestureRecognizer(self.tapGesture)
            self.isOverlay = false
            self.okButton.setTitle("OK", for: .normal)
            self.okButton.isHidden = true
        } else {
            if self.coords.count == 0 {
                self.dismiss(animated: true, completion: nil)
            } else {
                let _ = self.coords.popLast()
                let xmark = self.xmarks.popLast()
                xmark?.removeFromSuperview()
                self.okButton.isHidden = true
            }
        }
        self.tapGesture.isEnabled = true
    }
    
    @objc func okAction(sender: UIButton) {
        if !self.isOverlay {
            startAnimating(CGSize(width: 80, height: 80), message: "Processing...", type: NVActivityIndicatorType.pacman, color: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), backgroundColor: UIColor(displayP3Red: 128, green: 128, blue: 128, alpha: 0.3), textColor: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))
            
            DispatchQueue.global().async {
                let resImgs: [UIImage] = CVHelper.makeOverlayMask(image: self.image, coords: self.coords)
                let maskImg: UIImage = resImgs[0]
                let overlayImg: UIImage = resImgs[1]
                
                self.saveImageToDocumentDirectory(image: maskImg)
                
                DispatchQueue.main.async {
                    self.stopAnimating()
                    self.okButton.isHidden = true
                    self.coords.removeAll()
                    for xmark in self.xmarks {
                        xmark.removeFromSuperview()
                    }
                    self.xmarks.removeAll()
                    self.scrollView.display(image: overlayImg)
                    self.isOverlay = true
                    self.okButton.setTitle("Submit", for: .normal)
                    self.okButton.isHidden = false
                }
            }
        }
        else {
            startAnimating(CGSize(width: 80, height: 80), message: "VOS Processing...", type: NVActivityIndicatorType.pacman, color: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), backgroundColor: UIColor(displayP3Red: 128, green: 128, blue: 128, alpha: 0.3), textColor: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))
            
            let vosSession = VOSSession()
            var segURL: URL? = nil
            var foreVideoURL: URL? = nil
            do {
                segURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                segURL = segURL?.appendingPathComponent("foreVideoNoAlpha.mp4")
                foreVideoURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                foreVideoURL = foreVideoURL?.appendingPathComponent("foreVideoWithAlpha.mov")
            } catch {
                print(error)
                return
            }
            
            DispatchQueue.global().async {
                vosSession.run(videoURL: self.videoURL, maskURL: self.maskURL!, saveURL: segURL!)
                
                downloadSemaphore.wait()
                convertToHEVCAlpha(sourceURL: segURL!, destinationURL: foreVideoURL!)
                
                convertSemaphore.wait()
                DispatchQueue.main.async {
                    self.stopAnimating()
                    self.dismiss(animated: true) {
                        let stroyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let next = stroyboard.instantiateViewController(identifier: "editViewController") as? EditViewController else { return }
                        next.foreVideoURL = foreVideoURL
                        let topController = UIApplication.shared.windows[0].rootViewController as? UINavigationController
                        topController?.pushViewController(next, animated: true)
                    }
                }
            }
        }
    }
    
    func saveImageToDocumentDirectory(image: UIImage) {
        do {
            self.maskURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            self.maskURL = self.maskURL?.appendingPathComponent("mask.png")
            try? FileManager.default.removeItem(at: self.maskURL!)
            let pngData = image.pngData()
            try pngData?.write(to: self.maskURL!)
            print(self.maskURL as Any)
        } catch {
            print(error)
        }
    }
    
}
