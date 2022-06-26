import UIKit
import LocalAuthentication

class PasscodeViewController: UIViewController {

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
    
    private var passcode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "passcode") != nil {
            titleLabel.text = "Enter your passcode"
            setUpBiometrics()
        } else {
            titleLabel.text = "Setting up your passcode"
        }
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        if passcode.count != 4 {
            passcode += sender.titleLabel!.text!
            if passcode.count == 1 {
                firstPoint.textColor = .white
            } else if passcode.count == 2 {
                firstPoint.textColor = .white
                secondPoint.textColor = .white
            } else if passcode.count == 3 {
                firstPoint.textColor = .white
                secondPoint.textColor = .white
                thirdPoint.textColor = .white
            } else {
                disableButtons(true)
                
                if UserDefaults.standard.string(forKey: "passcode") != nil {
                    if passcode == UserDefaults.standard.string(forKey: "passcode") {
                        performSegue(withIdentifier: "PasscodeToHome", sender: self)
                    } else {
                        passcode = ""
                        titleLabel.text = "Invalid passcode"
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
            firstPoint.textColor = .white
            secondPoint.textColor = .white
            thirdPoint.textColor = .white
            fourthPoint.textColor = .white
            
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
            firstPoint.textColor = .gray
            secondPoint.textColor = .gray
            thirdPoint.textColor = .gray
            fourthPoint.textColor = .gray
            
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
        let reason = "Please, allow to continue with Touch ID."
        var error: NSError? = nil
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    guard success, error == nil else { return }
                    
                    self!.performSegue(withIdentifier: "PasscodeToHome", sender: self)
                }
            }
        }
    }
}
