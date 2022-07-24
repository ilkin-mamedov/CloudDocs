import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SPAlert

class AccountViewController: UIViewController {
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let actions = ["Edit name".localized(), "Edit e-mail address".localized(), "Edit password".localized(), "Delete account".localized()]
    
    var email = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        user = Auth.auth().currentUser
        
        userImageView.layer.cornerRadius = 100
        
        if let safeUser = user {
            userImageView.sd_setImage(with: safeUser.photoURL, placeholderImage: UIImage(named: "Account"))
            nameLabel.text = safeUser.displayName
            emailLabel.text = safeUser.email
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
        
        alert.view.tintColor = UIColor(named: "AccentColor")
        
        let signOut = UIAlertAction(title: "Sign Out".localized(), style: .destructive) { action in
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "AccountToWelcome", sender: self)
                UserDefaults.standard.removeObject(forKey: "passcode")
            } catch {
                print(error)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel) { _ in
            alert.self.dismiss(animated: true)
        }
        
        alert.addAction(signOut)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func editPhotoPressed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = false
            
            self.present(self.imagePicker, animated: true)
        }
    }
}

extension AccountViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in })
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        userImageView.image = image
        
        let accountRef = storageRef!.child("\(user!.uid)/account.png")
        
        let accountUpload = accountRef.putData(image.pngData()!, metadata: nil) { (metadata, error) in
            accountRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                
                let changeRequest = self.user!.createProfileChangeRequest()
                changeRequest.photoURL = downloadURL
                changeRequest.commitChanges()
            }
        }
        
        accountUpload.resume()
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = actions[indexPath.row]
        
        if indexPath.row == (actions.count - 1) {
            cell.textLabel?.textColor = .systemRed
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && !email.isEmpty && !password.isEmpty {
            let nameAlert = UIAlertController(title: "What is your name?".localized(), message: "", preferredStyle: .alert)
            
            nameAlert.view.tintColor = UIColor(named: "AccentColor")
            
            nameAlert.addTextField { textField in
                textField.placeholder = ""
                textField.text = self.user!.displayName
            }
            
            let cancel = UIAlertAction(title: "Cancel".localized(), style: .destructive) { _ in
                nameAlert.self.dismiss(animated: true)
            }
            
            let save = UIAlertAction(title: "Save".localized(), style: .default) { action in
                let changeRequest = self.user!.createProfileChangeRequest()
                changeRequest.displayName = nameAlert.textFields![0].text
                changeRequest.commitChanges()
                self.nameLabel.text = nameAlert.textFields![0].text
                SPAlert.present(title: "Name is Changed".localized(), preset: .done)
            }
            
            nameAlert.addAction(cancel)
            nameAlert.addAction(save)
            
            self.present(nameAlert, animated: true, completion: nil)
        } else if indexPath.row == 1 && !email.isEmpty && !password.isEmpty {
            let emailAlert = UIAlertController(title: "E-mail Address".localized(), message: "", preferredStyle: .alert)
            
            emailAlert.view.tintColor = UIColor(named: "AccentColor")
            
            emailAlert.addTextField { textField in
                textField.placeholder = ""
                textField.text = self.user!.email
            }
            
            let cancel = UIAlertAction(title: "Cancel".localized(), style: .destructive) { _ in
                emailAlert.self.dismiss(animated: true)
            }
            
            let save = UIAlertAction(title: "Save".localized(), style: .default) { action in
                let credential = EmailAuthProvider.credential(withEmail: self.email, password: self.password)
                
                self.user!.reauthenticate(with: credential) { result, error  in
                    if error != nil {
                        SPAlert.present(title: "Error", preset: .error)
                    } else {
                        self.user!.updateEmail(to: emailAlert.textFields![0].text!) { error in
                            if error != nil {
                                SPAlert.present(title: "Error", preset: .error)
                            } else {
                                self.emailLabel.text = emailAlert.textFields![0].text!
                                SPAlert.present(title: "E-mail Address is Changed".localized(), preset: .done)
                            }
                        }
                    }
                }
            }
            
            emailAlert.addAction(cancel)
            emailAlert.addAction(save)
            
            self.present(emailAlert, animated: true, completion: nil)
        } else if indexPath.row == 2 && !email.isEmpty && !password.isEmpty {
            let passwordAlert = UIAlertController(title: "Password".localized(), message: "", preferredStyle: .alert)
            
            passwordAlert.view.tintColor = UIColor(named: "AccentColor")
            
            passwordAlert.addTextField { textField in
                textField.isSecureTextEntry = true
                textField.placeholder = "Password"
            }
            
            passwordAlert.addTextField { textField in
                textField.isSecureTextEntry = true
                textField.placeholder = "Confirm Password"
            }
            
            let cancel = UIAlertAction(title: "Cancel".localized(), style: .destructive) { _ in
                passwordAlert.self.dismiss(animated: true)
            }
            
            let save = UIAlertAction(title: "Save".localized(), style: .default) { action in
                let credential = EmailAuthProvider.credential(withEmail: self.email, password: self.password)
                
                self.user!.reauthenticate(with: credential) { result, error  in
                    if error != nil {
                        SPAlert.present(title: "Error", preset: .error)
                    } else {
                        self.user!.updatePassword(to: passwordAlert.textFields![0].text!) { error in
                            SPAlert.present(title: "Password is Changed".localized(), preset: .done)
                        }
                    }
                }
            }
            
            passwordAlert.addAction(cancel)
            passwordAlert.addAction(save)
            
            self.present(passwordAlert, animated: true, completion: nil)
        } else if indexPath.row == 3 && !email.isEmpty && !password.isEmpty  {
            user!.delete { error in
                if error != nil {
                    SPAlert.present(title: "Error", preset: .error)
                } else {
                    do {
                        try Auth.auth().signOut()
                        self.performSegue(withIdentifier: "AccountToWelcome", sender: self)
                        UserDefaults.standard.removeObject(forKey: "passcode")
                    } catch {
                        print(error)
                    }
                }
            }
        } else {
            signIn()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func signIn() {
        let signInAlert = UIAlertController(title: "Sign In to Edit Account".localized(), message: .none, preferredStyle: .alert)
        
        signInAlert.view.tintColor = UIColor(named: "AccentColor")
        
        signInAlert.addTextField { textField in
            textField.placeholder = "E-mail Address".localized()
        }
        
        signInAlert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password".localized()
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .destructive) { _ in
            signInAlert.self.dismiss(animated: true)
        }
        
        let signIn = UIAlertAction(title: "Sign In".localized(), style: .default) { action in
            self.email = signInAlert.textFields![0].text!
            self.password = signInAlert.textFields![1].text!
        }
        
        signInAlert.addAction(cancel)
        signInAlert.addAction(signIn)
        
        self.present(signInAlert, animated: true, completion: nil)
    }
}
