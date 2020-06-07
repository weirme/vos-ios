import Foundation
import Alamofire


class VOSSession {
    let serverUrlPath: String = "http://192.168.1.106/"
    let key: String = String.randomStr(len: 8)
    var segmentationVideoURL: URL?
    
    func run(videoURL: URL, maskURL: URL, saveURL: URL) {
        Alamofire.upload(multipartFormData: { multipart in
            multipart.append(videoURL, withName: "video", fileName: "in.mp4", mimeType: "mp4")
            multipart.append(maskURL, withName: "mask", fileName: "ma.png", mimeType: "png")
            multipart.append(self.key.data(using: .utf8)!, withName :"key")
        }, to: self.serverUrlPath + "upload", method: .post, headers: nil) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { answer in
                    let resDict: [String : String] = answer.result.value as! [String : String]
                    let segmentationURL = URL(string: self.serverUrlPath + resDict["seg_path"]!)
                    self.download(fromURL: segmentationURL!, toURL: saveURL)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func download(fromURL: URL, toURL: URL) {
        do {
            try FileManager.default.removeItem(at: toURL)
        } catch {}
        let request = URLRequest(url: fromURL)
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: request, completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in
            print("location:\(String(describing: location))")
            let fileManager = FileManager.default
            try! fileManager.moveItem(at: location!, to: toURL)
            print("new location:\(toURL)")
            downloadSemaphore.signal()
            })
        
        downloadTask.resume()
    }
}


extension String{
    static let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static func randomStr(len : Int) -> String{
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
}

