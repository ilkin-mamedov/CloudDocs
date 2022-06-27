import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SPAlert

class DocumentViewController: UIViewController {
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    
    var id = ""
    
    var fields = [DocumentField]()
    
    @IBOutlet weak var documentFieldsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        user = Auth.auth().currentUser
        
        ref.child("users").child(user!.uid).child("documents").child(id).observeSingleEvent(of: .value) { snapshot in
            if let dict = snapshot.value as? [String : AnyObject] {
                self.title = (dict["type"] as! String)
                for item in dict {
                    if item.key == "type" {
                        continue
                    }
                    self.fields.append(DocumentField(title: item.key, subtitle: (item.value as! String)))
                }
            }
            self.documentFieldsTableView.reloadData()
        }
        
        documentFieldsTableView.delegate = self
        documentFieldsTableView.dataSource = self
        documentFieldsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DocumentFieldCell")
    }
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Do you really want to delete this document?", message: "", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor(named: "AccentColor")
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { _ in
            alert.self.dismiss(animated: true)
        }
        
        let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.ref.child("users").child(self.user!.uid).child("documents").child(self.id).removeValue()
            self.storageRef!.child("\(self.user!.uid)/documents/\(self.id).png").delete { _ in }
            SPAlert.present(title: "Deleted Document", preset: .done)
            self.navigationController!.popViewController(animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        
        self.present(alert, animated: true, completion: {
            alert.view.tintColor = UIColor(named: "AccentColor")
        })
    }
}

extension DocumentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "DocumentFieldCell")
        
        let field = fields[indexPath.row]
        
        cell.textLabel!.text = field.title
        cell.detailTextLabel!.text = field.subtitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        documentFieldsTableView.deselectRow(at: indexPath, animated: true)
    }
}
