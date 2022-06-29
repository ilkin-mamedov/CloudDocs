import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
   
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barStyle = .black
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "WelcomeToPasscode", sender: self)
        }
        
        signUpButton.layer.cornerRadius = 5
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.white.cgColor
        signInButton.layer.cornerRadius = 5
        
        captionAnimation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WelcomeToSignUp" || segue.identifier == "WelcomeToSignIn" {
            navigationController!.navigationBar.barStyle = .default
        }
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
