import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SPAlert

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
    
    @IBOutlet weak var documentFieldsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        user = Auth.auth().currentUser
        
        documentDataSource.type = type!
        fields = documentDataSource.fields
        
        title = Document.typeToString(type: type!)
        
        ref.child("users").child(self.user!.uid).child("documents").child(self.documentID).child("type").setValue(Document.typeToString(type: type!))
        
        documentFieldsTableView.delegate = self
        documentFieldsTableView.dataSource = self
        documentFieldsTableView.register(UINib(nibName: "AddPhotoButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "AddPhotoButtonTableViewCell")
        documentFieldsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DocumentFieldCell")
    }
    
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        SPAlert.present(title: "Added Document", preset: .done)
        isAdded = true
        dismiss(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !isAdded {
            ref.child("users").child(self.user!.uid).child("documents").child(self.documentID).removeValue()
            storageRef!.child("\(user!.uid)/documents/\(documentID).png").delete { _ in }
        }
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
}

extension AddDocumentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : fields!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = documentFieldsTableView.dequeueReusableCell(withIdentifier: "AddPhotoButtonTableViewCell", for: indexPath) as! AddPhotoButtonTableViewCell
            
            cell.addPhotoButton.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
            
            return cell
        } else {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "DocumentFieldCell")
            
            let field = fields![indexPath.row]
            
            cell.textLabel!.text = field.title
            cell.detailTextLabel!.text = field.subtitle
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            documentFieldsTableView.deselectRow(at: indexPath, animated: true)
        } else {
            let field = fields![indexPath.row]
            
            let alert = UIAlertController(title: field.title, message: "", preferredStyle: .alert)

            alert.view.tintColor = UIColor(named: "AccentColor")

            alert.addTextField { textField in textField.placeholder = "" }

            let cancel = UIAlertAction(title: "Cancel", style: .default) { _ in
                alert.self.dismiss(animated: true)
            }

            let save = UIAlertAction(title: "Save", style: .default) { action in
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
                sender.setTitle("Photo uploaded", for: .normal)
                sender.isEnabled = false
                sender.backgroundColor = UIColor(named: "AddDocumentBackgroundColor")
            }
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
