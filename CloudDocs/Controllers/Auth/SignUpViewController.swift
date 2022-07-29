import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var confirmPasswordTextField: TextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.tintColor = UIColor(named: "AccentColor")
        
        nameTextField.layer.cornerRadius = 5
        emailTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        confirmPasswordTextField.layer.cornerRadius = 5
        signUpButton.layer.cornerRadius = 5
        
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "What is your name?".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "E-mail Address".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: "Confirm Password".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
        navigationController!.navigationBar.barStyle = .black
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
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("isPremium").setValue(false)
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
