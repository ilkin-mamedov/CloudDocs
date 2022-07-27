import UIKit
import FirebaseAuth
import SnackBar_swift
import SPAlert

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgottenPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.tintColor = UIColor(named: "AccentColor")
        
        emailTextField.delegate = self
        emailTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        signInButton.layer.cornerRadius = 5
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "E-mail Address".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
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
                if error == nil {
                    self!.performSegue(withIdentifier: "SignInToPasscode", sender: self)
                } else {
                    AppSnackBar.make(in: self!.view, message: error!.localizedDescription.localized(), duration: .lengthLong).show()
                }
            }
        }
    }
    
    
    @IBAction func forgottenPasswordPressed(_ sender: UIButton) {
        if !emailTextField.text!.isEmpty {
            Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
                if error == nil {
                    SPAlert.present(title: "Please, check your e-mail".localized(), preset: .done)
                } else {
                    SPAlert.present(title: "Error".localized(), preset: .error)
                }
            }
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        forgottenPasswordButton.isEnabled = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.isEmpty {
            forgottenPasswordButton.isEnabled = false
        } else {
            forgottenPasswordButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

class AppSnackBar: SnackBar {
    
    override var style: SnackBarStyle {
        var style = SnackBarStyle()
        style.background = UIColor(named: "AccentColor")!
        style.textColor = .white
        return style
    }
}
