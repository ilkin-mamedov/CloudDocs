import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SPAlert
import VisionKit

class AddDocumentViewController: UIViewController {
    
    var type: DocumentType?
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    var documentID = UUID().uuidString
    let documentDataSource = DocumentDataSource()
    var fields: [DocumentField]?
    var isAdded = false
    var imagePicker = UIImagePickerController()
    var documentsCount = 0
    
    @IBOutlet weak var documentFieldsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        user = Auth.auth().currentUser
        
        ref.child("users").child(self.user!.uid).child("documents").observe(.value) { snapshot in
            self.documentsCount = (snapshot.value as? [String : AnyObject])?.count ?? 0
        }
        
        documentDataSource.type = type!
        fields = documentDataSource.fields
        
        title = Document.typeToString(type: type!).localized()
        
        ref.child("users").child(self.user!.uid).child("documents").child(self.documentID).child("type").setValue(Document.typeToString(type: type!))
        
        documentFieldsTableView.delegate = self
        documentFieldsTableView.dataSource = self
        documentFieldsTableView.register(UINib(nibName: "AddButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "AddButtonTableViewCell")
        documentFieldsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DocumentFieldCell")
    }
    
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        SPAlert.present(title: "Added Document".localized(), preset: .done)
        isAdded = true
        dismiss(animated: true)
        if documentsCount == 1 {
            self.sendNotification()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !isAdded {
            ref.child("users").child(self.user!.uid).child("documents").child(self.documentID).removeValue()
            storageRef!.child("\(user!.uid)/documents/\(documentID).png").delete { _ in }
            storageRef!.child("\(user!.uid)/scans/\(documentID).png").delete { _ in }
        }
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "CloudDocs"
        content.body = "Congratulations! Your first document has been added. In the free version, you can add 2 more documents. To use all the features of CloudDocs, you can try premium.".localized()
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false))
        
        UNUserNotificationCenter.current().add(request)
    }
}

extension AddDocumentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return fields!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = documentFieldsTableView.dequeueReusableCell(withIdentifier: "AddButtonTableViewCell", for: indexPath) as! AddButtonTableViewCell
            
            cell.addButton.setTitle("Add photo of document".localized(), for: .normal)
            cell.addButton.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
            
            return cell
        } else if indexPath.section == 1 {
            let cell = documentFieldsTableView.dequeueReusableCell(withIdentifier: "AddButtonTableViewCell", for: indexPath) as! AddButtonTableViewCell
            
            cell.addButton.setTitle("Add scan of document".localized(), for: .normal)
            cell.addButton.addTarget(self, action: #selector(addScan), for: .touchUpInside)
            
            return cell
        } else {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "DocumentFieldCell")
            
            let field = fields![indexPath.row]
            
            cell.textLabel!.text = field.title.localized()
            cell.detailTextLabel!.text = field.subtitle
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            documentFieldsTableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.section == 1 {
            documentFieldsTableView.deselectRow(at: indexPath, animated: true)
        } else {
            let field = fields![indexPath.row]
            
            let alert = UIAlertController(title: field.title.localized(), message: "", preferredStyle: .alert)

            alert.view.tintColor = UIColor(named: "AccentColor")

            alert.addTextField { textField in textField.placeholder = "Optional" }

            let cancel = UIAlertAction(title: "Cancel".localized(), style: .default) { _ in
                alert.self.dismiss(animated: true)
            }

            let save = UIAlertAction(title: "Save".localized(), style: .default) { action in
                if let subtitle = alert.textFields![0].text, !subtitle.isEmpty {
                    self.ref.child("users").child(self.user!.uid).child("documents").child(self.documentID).child(field.title).setValue(subtitle)
                    tableView.cellForRow(at: indexPath)?.detailTextLabel!.text = subtitle
                }
            }

            alert.addAction(cancel)
            alert.addAction(save)

            present(alert, animated: true, completion: {
                alert.view.tintColor = UIColor(named: "AccentColor")
            })
            
            documentFieldsTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc func addPhoto(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true) {
                sender.setTitle("Uploaded".localized(), for: .normal)
                sender.isEnabled = false
                sender.backgroundColor = UIColor(named: "AddDocumentBackgroundColor")
            }
        }
    }
    
    @objc func addScan(sender: UIButton) {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true) {
            self.ref.child("users").child(self.user!.uid).child("documents").child(self.documentID).child("type").setValue(Document.typeToString(type: self.type!))
            sender.setTitle("Uploaded".localized(), for: .normal)
            sender.isEnabled = false
            sender.backgroundColor = UIColor(named: "AddDocumentBackgroundColor")
        }
    }
}

extension AddDocumentViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in })
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let upload = storageRef!.child("\(user!.uid)/documents/\(documentID).png").putData(image.pngData()!, metadata: nil) { (metadata, error) in }
        
        upload.resume()
    }
}

extension AddDocumentViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let upload = storageRef!.child("\(user!.uid)/scans/\(documentID).png").putData(scan.imageOfPage(at: 0).pngData()!, metadata: nil) { (metadata, error) in }
        
        upload.resume()
        dismiss(animated: true)
    }
}
