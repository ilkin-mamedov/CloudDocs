import UIKit
import FirebaseAuth
import LocalAuthentication

class PasscodeViewController: UIViewController {

    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var firstPoint: UILabel!
    @IBOutlet weak var secondPoint: UILabel!
    @IBOutlet weak var thirdPoint: UILabel!
    @IBOutlet weak var fourthPoint: UILabel!
    
    @IBOutlet weak var oneNumberButton: UIButton!
    @IBOutlet weak var twoNumberButton: UIButton!
    @IBOutlet weak var threeNumberButton: UIButton!
    @IBOutlet weak var fourNumberButton: UIButton!
    @IBOutlet weak var fiveNumberButton: UIButton!
    @IBOutlet weak var sixNumberButton: UIButton!
    @IBOutlet weak var sevenNumberButton: UIButton!
    @IBOutlet weak var eightNumberButton: UIButton!
    @IBOutlet weak var nineNumberButton: UIButton!
    @IBOutlet weak var zeroNumberButton: UIButton!
    @IBOutlet weak var biometricsButton: UIButton!
    
    private var passcode = ""
    
    let context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser!.photoURL != nil {
            accountImageView.sd_setImage(with: Auth.auth().currentUser!.photoURL)
            accountImageView.sd_setImage(with: Auth.auth().currentUser!.photoURL, placeholderImage: UIImage(named: "Account"))
        } else {
            accountImageView.image = UIImage(named: "Account")
        }
        
        accountImageView.layer.cornerRadius = 35
        
        if UserDefaults.standard.string(forKey: "passcode") != nil {
            if let user = Auth.auth().currentUser {
                setUpBiometrics()
                titleLabel.text = user.displayName!
                if context.biometryType == .touchID {
                    biometricsButton.setImage(UIImage(systemName: "touchid"), for: .normal)
                } else if context.biometryType == .faceID {
                    biometricsButton.setImage(UIImage(systemName: "faceid"), for: .normal)
                } else {
                    biometricsButton.isEnabled = false
                }
            }
        } else {
            titleLabel.text = "Setting up your passcode".localized()
        }
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        if passcode.count != 4 {
            passcode += sender.titleLabel!.text!
            if passcode.count == 1 {
                firstPoint.textColor = UIColor(named: "AccentColor")
            } else if passcode.count == 2 {
                firstPoint.textColor = UIColor(named: "AccentColor")
                secondPoint.textColor = UIColor(named: "AccentColor")
            } else if passcode.count == 3 {
                firstPoint.textColor = UIColor(named: "AccentColor")
                secondPoint.textColor = UIColor(named: "AccentColor")
                thirdPoint.textColor = UIColor(named: "AccentColor")
            } else {
                disableButtons(true)
                
                if UserDefaults.standard.string(forKey: "passcode") != nil {
                    if passcode == UserDefaults.standard.string(forKey: "passcode") {
                        titleLabel.text = "Welcome".localized()
                        performSegue(withIdentifier: "PasscodeToHome", sender: self)
                    } else {
                        passcode = ""
                        titleLabel.text = "Invalid passcode".localized()
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        disableButtons(false)
                    }
                } else {
                    UserDefaults.standard.set(passcode, forKey: "passcode")
                    performSegue(withIdentifier: "PasscodeToHome", sender: self)
                }
            }
        }
    }
    
    private func disableButtons(_ isDisable: Bool) {
        if isDisable {
            firstPoint.textColor = UIColor(named: "AccentColor")
            secondPoint.textColor = UIColor(named: "AccentColor")
            thirdPoint.textColor = UIColor(named: "AccentColor")
            fourthPoint.textColor = UIColor(named: "AccentColor")
            
            oneNumberButton.isEnabled = false
            twoNumberButton.isEnabled = false
            threeNumberButton.isEnabled = false
            fourNumberButton.isEnabled = false
            fiveNumberButton.isEnabled = false
            sixNumberButton.isEnabled = false
            sevenNumberButton.isEnabled = false
            eightNumberButton.isEnabled = false
            nineNumberButton.isEnabled = false
            zeroNumberButton.isEnabled = false
        } else {
            firstPoint.textColor = UIColor(named: "PointColor")
            secondPoint.textColor = UIColor(named: "PointColor")
            thirdPoint.textColor = UIColor(named: "PointColor")
            fourthPoint.textColor = UIColor(named: "PointColor")
            
            oneNumberButton.isEnabled = true
            twoNumberButton.isEnabled = true
            threeNumberButton.isEnabled = true
            fourNumberButton.isEnabled = true
            fiveNumberButton.isEnabled = true
            sixNumberButton.isEnabled = true
            sevenNumberButton.isEnabled = true
            eightNumberButton.isEnabled = true
            nineNumberButton.isEnabled = true
            zeroNumberButton.isEnabled = true
        }
    }
    
    private func setUpBiometrics() {
        let context = LAContext()
        let reason = "Please, allow to continue with Touch ID.".localized()
        var error: NSError? = nil
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    guard success, error == nil else { return }
                    self!.firstPoint.textColor = UIColor(named: "AccentColor")
                    self!.secondPoint.textColor = UIColor(named: "AccentColor")
                    self!.thirdPoint.textColor = UIColor(named: "AccentColor")
                    self!.fourthPoint.textColor = UIColor(named: "AccentColor")
                    self!.performSegue(withIdentifier: "PasscodeToHome", sender: self)
                }
            }
        }
    }
    
    @IBAction func biometricsPressed(_ sender: UIButton) {
        setUpBiometrics()
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        if UserDefaults.standard.string(forKey: "passcode") != nil {
            titleLabel.text = "Enter your passcode".localized()
        } else {
            titleLabel.text = "Setting up your passcode".localized()
        }
        
        firstPoint.textColor = UIColor(named: "PointColor")
        secondPoint.textColor = UIColor(named: "PointColor")
        thirdPoint.textColor = UIColor(named: "PointColor")
        fourthPoint.textColor = UIColor(named: "PointColor")
        
        passcode = ""
    }
}
