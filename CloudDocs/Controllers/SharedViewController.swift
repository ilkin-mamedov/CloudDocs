import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import SPAlert

class SharedViewController: UIViewController {

    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    
    var path = ""
    var timeRemaining = 30
    
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var documentImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main) { notification in
                self.dismiss(animated: true)
        }
        
        title = "\(timeRemaining)"
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        user = Auth.auth().currentUser
        
        storageRef!.child(path).downloadURL { url, error in
            guard let downloadURL = url else {
                if error != nil {
                    self.storageRef!.child(self.path).downloadURL { url, error in
                        guard let downloadURL = url else {
                            if error != nil {
                                print(error!)
                                SPAlert.present(title: "Error".localized(), preset: .error)
                            }
                            return
                        }
                        
                        self.documentImageView.sd_setImage(with: downloadURL) { _, _, _, _ in
                            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.running), userInfo: nil, repeats: true)
                        }
                    }
                    print(error!)
                    SPAlert.present(title: "Error".localized(), preset: .error)
                }
                return
            }
            
            self.documentImageView.sd_setImage(with: downloadURL) { _, _, _, _ in
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.running), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func running() {
        if timeRemaining == 0 {
            dismiss(animated: true)
        } else {
            timeRemaining -= 1
            UIView.animate(withDuration: 1) {
                self.title = "\(self.timeRemaining)"
                self.progressBarView.setProgress(Float(self.timeRemaining) / Float(30), animated: true)
            }
        }
    }
}
