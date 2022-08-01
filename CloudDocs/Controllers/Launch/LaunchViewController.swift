import UIKit
import FirebaseAuth
import FirebaseDatabase
import LocalAuthentication

class LaunchViewController: UIViewController {
    
    var ref: DatabaseReference!
    var user: User?

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var appLabel: UILabel!
    
    var isPremium = false
    var subscriptionValidUntil = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black
        
        ref = Database.database().reference()
        user = Auth.auth().currentUser
        
        ref.child("users").child(user!.uid).child("isPremium").observe(.value, with: { snapshot in
            self.isPremium = snapshot.value as? Bool ?? false
        })
        
        ref.child("users").child(user!.uid).child("subscriptionValidUntil").observe(.value, with: { snapshot in
            self.subscriptionValidUntil = snapshot.value as? String ?? ""
        })
        
        logoImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        UIView.animate(withDuration: 1.0) {
            self.logoImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.appLabel.alpha = 1.0
        } completion: { _ in
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                if self.user != nil {
                    if self.isPremium {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd.MM.yyyy"
                        let todayDate = dateFormatter.string(from: Date.now)
                        if self.subscriptionValidUntil == todayDate {
                            self.ref.child("users").child(self.user!.uid).child("isPremium").setValue(false)
                            self.ref.child("users").child(self.user!.uid).child("subscriptionValidUntil").removeValue()
                        }
                    }
                    self.performSegue(withIdentifier: "LaunchToPasscode", sender: self)
                } else {
                    self.performSegue(withIdentifier: "LaunchToWelcome", sender: self)
                }
            }
        }
    }
}
