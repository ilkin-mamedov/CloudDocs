import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.tintColor = UIColor(named: "AccentColor")
        
        emailTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        signInButton.layer.cornerRadius = 5
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "E-mail Address",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
        navigationController!.navigationBar.barStyle = .black
    }
    
    private func isEmptyFields() -> Bool {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if !isEmptyFields() {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                self!.performSegue(withIdentifier: "SignInToPasscode", sender: self)
            }
        }
    }
}
