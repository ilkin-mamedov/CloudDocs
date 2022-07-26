import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import SPAlert

class DocumentViewController: UIViewController {
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    
    var id = ""
    var path = ""
    
    var fields = [DocumentField]()
    
    @IBOutlet weak var documentFieldsTableView: UITableView!
    @IBOutlet weak var generateQRCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        user = Auth.auth().currentUser
        
        ref.child("users").child(user!.uid).child("documents").child(id).observeSingleEvent(of: .value) { snapshot in
            if let dict = snapshot.value as? [String : AnyObject] {
                self.title = (dict["type"] as! String).localized()
                for item in dict {
                    if item.key == "type" {
                        continue
                    }
                    self.fields.append(DocumentField(title: item.key, subtitle: (item.value as! String)))
                }
            }
            self.fields.sort { field1, field2 in
                return field1.title < field2.title
            }
            self.documentFieldsTableView.reloadData()
        }
        
        documentFieldsTableView.delegate = self
        documentFieldsTableView.dataSource = self
        documentFieldsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DocumentFieldCell")
        documentFieldsTableView.register(UINib(nibName: "PhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "PhotoTableViewCell")
        generateQRCodeButton.layer.cornerRadius = 5
    }
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Do you really want to delete this document?".localized(), message: "", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor(named: "AccentColor")
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .default) { _ in
            alert.self.dismiss(animated: true)
        }
        
        let delete = UIAlertAction(title: "Delete".localized(), style: .destructive) { action in
            self.ref.child("users").child(self.user!.uid).child("documents").child(self.id).removeValue()
            self.storageRef!.child("\(self.user!.uid)/documents/\(self.id).png").delete { _ in }
            self.storageRef!.child("\(self.user!.uid)/scans/\(self.id).png").delete { _ in }
            SPAlert.present(title: "Deleted Document".localized(), preset: .done)
            self.navigationController!.popViewController(animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        
        self.present(alert, animated: true, completion: {
            alert.view.tintColor = UIColor(named: "AccentColor")
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DocumentToPreview" {
            let previewViewController = segue.destination as! PreviewViewController
            previewViewController.id = id
        } else if segue.identifier == "DocumentToQRCode" {
            let qrCodeViewController = segue.destination as! QRCodeViewController
            qrCodeViewController.path = path
        }
    }
    
    @IBAction func generateQRCodePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "DocumentToQRCode", sender: self)
    }
}

extension DocumentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == fields.count {
            let cell = documentFieldsTableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
            
            cell.indicatorView.startAnimating()
            
            storageRef!.child("\(self.user!.uid)/documents/\(self.id).png").downloadURL { url, error in
                guard let downloadURL = url else {
                    if error != nil {
                        self.storageRef!.child("\(self.user!.uid)/scans/\(self.id).png").downloadURL { url, error in
                            guard let downloadURL = url else {
                                if error != nil {
                                    cell.indicatorView.stopAnimating()
                                    cell.indicatorView.isHidden = true
                                    print(error!)
                                }
                                return
                            }
                            
                            cell.photoImageView.sd_setImage(with: downloadURL) { _, _, _, _ in
                                cell.indicatorView.stopAnimating()
                                cell.indicatorView.isHidden = true
                                self.generateQRCodeButton.isEnabled = true
                                self.path = "\(self.user!.uid)/scans/\(self.id).png"
                                self.generateQRCodeButton.backgroundColor = UIColor(named: "AccentColor")
                            }
                        }
                        print(error!)
                    }
                    return
                }
                
                cell.photoImageView.sd_setImage(with: downloadURL) { _, _, _, _ in
                    cell.indicatorView.stopAnimating()
                    cell.indicatorView.isHidden = true
                    self.path = "\(self.user!.uid)/documents/\(self.id).png"
                    self.generateQRCodeButton.isEnabled = true
                    self.generateQRCodeButton.backgroundColor = UIColor(named: "AccentColor")
                }
            }
            
            return cell
        } else {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "DocumentFieldCell")
            
            let field = fields[indexPath.row]
            
            cell.textLabel!.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.textLabel!.text = field.title.localized()
            cell.detailTextLabel!.text = field.subtitle
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != fields.count {
            UIPasteboard.general.string = fields[indexPath.row].subtitle
            SPAlert.present(title: "Copied to Clipboard".localized(), preset: .done)
        } else {
            performSegue(withIdentifier: "DocumentToPreview", sender: self)
        }
        documentFieldsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == fields.count {
            return 200
        } else {
            return 44
        }
    }
}
