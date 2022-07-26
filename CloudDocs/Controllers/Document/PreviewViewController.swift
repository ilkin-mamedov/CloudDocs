import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class PreviewViewController: UIViewController {
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    
    var id = ""

    @IBOutlet weak var documentImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        user = Auth.auth().currentUser
        
        storageRef!.child("\(user!.uid)/documents/\(id).png").downloadURL { url, error in
            guard let downloadURL = url else {
                if error != nil {
                    self.storageRef!.child("\(self.user!.uid)/scans/\(self.id).png").downloadURL { url, error in
                        guard let downloadURL = url else {
                            if error != nil {
                                print(error!)
                            }
                            return
                        }
                        
                        self.documentImageView.sd_setImage(with: downloadURL)
                    }
                    print(error!)
                }
                return
            }
            
            self.documentImageView.sd_setImage(with: downloadURL)
        }
    }
}
