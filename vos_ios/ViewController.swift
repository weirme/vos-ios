//
//  ViewController.swift
//  vos_ios
//
//  Created by re on 2020/2/16.
//  Copyright © 2020 weirme. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func click(_ sender: Any) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.modalPresentationStyle = .overFullScreen
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = ["public.movie"]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let videoURL = info[.mediaURL] as! URL
        let image : UIImage = previewImageFromVideo(url: videoURL)!

        picker.dismiss(animated: true, completion: {
            let drawPointView = DrawPointController()
            drawPointView.image = image
            self.present(drawPointView, animated: true, completion: nil)
        })
    }
    
    func previewImageFromVideo(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value,2)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }

}
