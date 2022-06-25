import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var addDocumentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.prefersLargeTitles = true
        
        if let user = Auth.auth().currentUser {
            title = "Greetings, \(user.displayName!)!"
        }
        
        addDocumentButton.layer.cornerRadius = 28
        addDocumentButton.setTitle("", for: .normal)
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "HomeToWelcome", sender: self)
        } catch {
            print(error)
        }
    }
}
