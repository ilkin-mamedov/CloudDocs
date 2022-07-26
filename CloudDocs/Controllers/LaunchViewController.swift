import UIKit
import FirebaseAuth

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "LaunchToPasscode", sender: self)
        } else {
            performSegue(withIdentifier: "LaunchToWelcome", sender: self)
        }
    }
}
