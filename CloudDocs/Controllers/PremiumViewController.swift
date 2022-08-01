import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SPAlert

class PremiumViewController: UIViewController {

    let features = [
        "Unlimited documents".localized(),
        "Share your documents with CloudDocs Sharing".localized(),
        "Saving photo of document".localized(),
        "Saving scan of document".localized(),
    ]
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subscribeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        user = Auth.auth().currentUser
        
        subscribeButton.layer.cornerRadius = 5
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeatureTableViewCell", bundle: nil), forCellReuseIdentifier: "FeatureTableViewCell")
    }
    
    @IBAction func closePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func subscribePressed(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let subscriptionValidUntil = dateFormatter.string(from: Calendar.current.date(byAdding: .month, value: +1, to: Date())!)
        ref.child("users").child(user!.uid).child("isPremium").setValue(true)
        ref.child("users").child(user!.uid).child("subscriptionValidUntil").setValue(subscriptionValidUntil)
        SPAlert.present(title: "You are subscribed!".localized(), preset: .done)
        dismiss(animated: true)
    }
}

extension PremiumViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeatureTableViewCell", for: indexPath) as! FeatureTableViewCell
        
        cell.titleLabel.text = features[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
