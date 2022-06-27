import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var confirmPasswordTextField: TextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.tintColor = .white
        
        nameTextField.layer.cornerRadius = 5
        emailTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        confirmPasswordTextField.layer.cornerRadius = 5
        signUpButton.layer.cornerRadius = 5
        
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "What is your name?",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "E-mail Address",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: "Confirm Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
    }
    
    private func isEmptyFields() -> Bool {
        if nameTextField.text!.isEmpty || emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty || confirmPasswordTextField.text!.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    private func isPasswordValid() -> Bool{
        if passwordTextField.text! == confirmPasswordTextField.text!
            && passwordTextField.text!.count >= 6
            && confirmPasswordTextField.text!.count >= 6 {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if !isEmptyFields() && isPasswordValid() {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest!.displayName = self.nameTextField.text!
                changeRequest!.commitChanges()
                self.performSegue(withIdentifier: "SignUpToPasscode", sender: self)
            }
        }
    }
}

class TextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}