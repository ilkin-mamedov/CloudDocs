import UIKit

class PremiumViewController: UIViewController {

    let features = [
        "Unlimited documents".localized(),
        "Share your documents with CloudDocs Sharing".localized(),
        "Saving photo of document".localized(),
        "Saving scan of document".localized(),
    ]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subscribeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeButton.layer.cornerRadius = 5
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeatureTableViewCell", bundle: nil), forCellReuseIdentifier: "FeatureTableViewCell")
    }
    
    @IBAction func closePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func subscribePressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Coming Soon".localized(), message: "This feature is currently not available.".localized(), preferredStyle: .alert)
        
        alert.view.tintColor = UIColor(named: "AccentColor")
        
        let cancel = UIAlertAction(title: "OK", style: .cancel) { _ in
            alert.self.dismiss(animated: true)
        }
        
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
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
