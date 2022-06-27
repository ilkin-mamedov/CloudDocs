import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import SPAlert

class AddDocumentViewController: UIViewController {
    
    var type: DocumentType?
    var ref: DatabaseReference!
    var user: User?
    var documentID = UUID().uuidString
    let documentDataSource = DocumentDataSource()
    var fields: [DocumentField]?
    var isAdded = false
    
    @IBOutlet weak var documentFieldsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
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
            self.ref.child("users").child(self.user!.uid).child("documents").child(self.documentID).removeValue()
        }
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
            return documentFieldsTableView.dequeueReusableCell(withIdentifier: "AddPhotoButtonTableViewCell", for: indexPath)
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
}
