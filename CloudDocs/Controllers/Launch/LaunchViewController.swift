import UIKit
import FirebaseAuth
import LocalAuthentication

class LaunchViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var appLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black
        
        logoImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        UIView.animate(withDuration: 1.0) {
            self.logoImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.appLabel.alpha = 1.0
        } completion: { _ in
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                if Auth.auth().currentUser != nil {
                    self.performSegue(withIdentifier: "LaunchToPasscode", sender: self)
                } else {
                    self.performSegue(withIdentifier: "LaunchToWelcome", sender: self)
                }
            }
        }
    }
}
