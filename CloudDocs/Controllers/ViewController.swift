import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var documentsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CloudDocs"
        navigationController!.navigationBar.prefersLargeTitles = true
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.tintColor = UIColor(named: "AccentColor")
        navigationItem.searchController = searchController
        
        documentsCollectionView.delegate = self
        documentsCollectionView.dataSource = self
        documentsCollectionView.register(UINib(nibName: "AddDocumentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AddDocumentCollectionViewCell")
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Do you really want to sign out?", message: "", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor(named: "AccentColor")
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { _ in
            alert.self.dismiss(animated: true)
        }
        
        let signOut = UIAlertAction(title: "Sign Out", style: .destructive) { action in
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "HomeToWelcome", sender: self)
                UserDefaults.standard.removeObject(forKey: "passcode")
            } catch {
                print(error)
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(signOut)
        
        self.present(alert, animated: true, completion: {
            alert.view.tintColor = UIColor(named: "AccentColor")
        })
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return documentsCollectionView.dequeueReusableCell(withReuseIdentifier: "AddDocumentCollectionViewCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print()
        return CGSize(width: (collectionView.bounds.width - 48) / 2, height: (collectionView.bounds.width - 48) / 2)
    }
}
