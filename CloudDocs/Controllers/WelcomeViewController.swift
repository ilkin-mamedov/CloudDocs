import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "WelcomeToPasscode", sender: self)
        }
        
        navigationController?.navigationBar.barStyle = .black
        
        signUpButton.layer.cornerRadius = 5
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.white.cgColor
        signInButton.layer.cornerRadius = 5
        
        captionAnimation()
    }
    
    private func captionAnimation() {
        var charIndex = 0.0
        let titleText = "The place where your documents live."
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.captionLabel.text?.append(letter)
            }
            charIndex += 1
        }
    }
}
