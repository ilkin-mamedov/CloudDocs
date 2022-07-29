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
    
    @IBOutlet weak var tableView: UITableView!
    
    let actions = ["Edit photo".localized(), "Edit name".localized(), "Edit e-mail address".localized(), "Edit password".localized(), "Delete account".localized()]
    
    var email = ""
    var password = ""
    var isPremium = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Account".localized()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        user = Auth.auth().currentUser
        
        ref.child("users").child(user!.uid).child("isPremium").observe(.value, with: { snapshot in
            self.isPremium = snapshot.value as! Bool
            self.tableView.reloadData()
        })
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AccountTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountTableViewCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc func signOutPressed() {
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
        
        present(alert, animated: true, completion: nil)
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as! AccountTableViewCell
            
            cell.accountImageView.sd_setImage(with: user?.photoURL, placeholderImage: UIImage(named: "Account"))
            if isPremium {
                cell.statusLabel.text = "PREMIUM".localized()
            } else {
                cell.statusLabel.text = "FREE".localized()
            }
            cell.nameLabel.text = user?.displayName
            cell.emailLabel.text = user?.email
            cell.signOutButton.addTarget(self, action: #selector(signOutPressed), for: .touchUpInside)
            
            return cell
        } else {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
            
            cell.textLabel?.text = actions[indexPath.row]
            
            if indexPath.row == 2 {
                cell.detailTextLabel?.textColor = .systemGray
                cell.detailTextLabel?.text = "Re-authentication required".localized()
            } else if indexPath.row == 3 {
                cell.detailTextLabel?.textColor = .systemGray
                cell.detailTextLabel?.text = "Re-authentication required".localized()
            } else if indexPath.row == 4 {
                cell.textLabel?.textColor = .systemRed
                cell.detailTextLabel?.textColor = .systemGray
                cell.detailTextLabel?.text = "Re-authentication required".localized()
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            if indexPath.row == 0 {
                if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = .savedPhotosAlbum
                    self.imagePicker.allowsEditing = false
                    
                    self.present(self.imagePicker, animated: true)
                }
            } else if indexPath.row == 1 {
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
                    (tableView.visibleCells[0] as! AccountTableViewCell).nameLabel.text = nameAlert.textFields![0].text
                    SPAlert.present(title: "Name is Changed".localized(), preset: .done)
                }
                
                nameAlert.addAction(cancel)
                nameAlert.addAction(save)
                
                self.present(nameAlert, animated: true, completion: nil)
            } else if indexPath.row == 2 && !email.isEmpty && !password.isEmpty {
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
                            SPAlert.present(title: "Error".localized(), preset: .error)
                        } else {
                            self.user!.updateEmail(to: emailAlert.textFields![0].text!) { error in
                                if error != nil {
                                    SPAlert.present(title: "Error".localized(), preset: .error)
                                } else {
                                    (tableView.visibleCells[0] as! AccountTableViewCell).emailLabel.text = emailAlert.textFields![0].text
                                    SPAlert.present(title: "E-mail Address is Changed".localized(), preset: .done)
                                }
                            }
                        }
                    }
                }
                
                emailAlert.addAction(cancel)
                emailAlert.addAction(save)
                
                self.present(emailAlert, animated: true, completion: nil)
            } else if indexPath.row == 3 && !email.isEmpty && !password.isEmpty {
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
                            SPAlert.present(title: "Error".localized(), preset: .error)
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
            } else if indexPath.row == 4 && !email.isEmpty && !password.isEmpty {
                let deleteAlert = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
                
                deleteAlert.view.tintColor = UIColor(named: "AccentColor")
                
                let deleteAccount = UIAlertAction(title: "Delete account".localized(), style: .destructive) { action in
                    self.ref.child("users").child(self.user!.uid).child("documents").observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists() {
                            SPAlert.present(title: "Please, delete all your documents".localized(), preset: .error)
                        } else {
                            let credential = EmailAuthProvider.credential(withEmail: self.email, password: self.password)
                            
                            self.user!.reauthenticate(with: credential) { result, error  in
                                if error != nil {
                                    SPAlert.present(title: "Error".localized(), preset: .error)
                                } else {
                                    self.user!.delete { error in
                                        if error != nil {
                                            SPAlert.present(title: "Error".localized(), preset: .error)
                                        } else {
                                            self.storageRef.child(self.user!.uid).child("account.png").delete { _ in }
                                            self.ref.child("users").child(self.user!.uid).child("isPremium").removeValue()
                                            do {
                                                try Auth.auth().signOut()
                                                self.performSegue(withIdentifier: "AccountToWelcome", sender: self)
                                                UserDefaults.standard.removeObject(forKey: "passcode")
                                            } catch {
                                                print(error)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel) { _ in
                    deleteAlert.self.dismiss(animated: true)
                }
                
                deleteAlert.addAction(deleteAccount)
                deleteAlert.addAction(cancel)
                
                present(deleteAlert, animated: true, completion: nil)
            } else {
                signIn()
            }
        } else {
            
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

extension AccountViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in })
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let accountRef = storageRef!.child("\(user!.uid)/account.png")
        
        let accountUpload = accountRef.putData(image.pngData()!, metadata: nil) { (metadata, error) in
            accountRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                
                let changeRequest = self.user!.createProfileChangeRequest()
                changeRequest.photoURL = downloadURL
                changeRequest.commitChanges()
                
                SPAlert.present(title: "Photo is Changed".localized(), preset: .done)
            }
        }
        
        accountUpload.resume()
    }
}
