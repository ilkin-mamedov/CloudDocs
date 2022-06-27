import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import SPAlert

class HomeViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var ref: DatabaseReference!
    var user: User?
    
    var documents = [Document]()
    var filteredDocuments = [Document]()
    
    @IBOutlet weak var documentsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CloudDocs"
        navigationController!.navigationBar.prefersLargeTitles = true
        searchController.searchBar.tintColor = UIColor(named: "AccentColor")
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.searchController = searchController
        
        ref = Database.database().reference()
        user = Auth.auth().currentUser
        
        ref.child("users").child(user!.uid).child("documents").observe(.value, with: { snapshot in
            self.documents.removeAll()
            if let dict = snapshot.value as? [String : AnyObject] {
                for child in dict {
                    if let name = child.value as? [String : AnyObject] {
                        let id = child.key
                        let type = Document.stringToType(string: name["type"] as? String ?? "Unknown")
                        var title = ""
                        
                        switch type {
                        case .nationalPassport:
                            title = name["Full name"] as? String ?? "Unknown"
                        case .internationalPassport:
                            title = name["Full name"] as? String ?? "Unknown"
                        case .birthCertificate:
                            title = name["Full name"] as? String ?? "Unknown"
                        case .foreignDocument:
                            title = name["Full name"] as? String ?? "Unknown"
                        case .snils:
                            title = name["Full name"] as? String ?? "Unknown"
                        case .inn:
                            title = name["Full name"] as? String ?? "Unknown"
                        case .oms:
                            title = name["Surname, name and patronymic"] as? String ?? "Unknown"
                        case .driversLicense:
                            title = name["Full name"] as? String ?? "Unknown"
                        case .vehicleRegID:
                            title = name["Make, model"] as? String ?? "Unknown"
                        case .vehiclePassport:
                            title = name["Make, model"] as? String ?? "Unknown"
                        case .osago:
                            title = name["Make, model"] as? String ?? "Unknown"
                        case .casco:
                            title = name["Make, model"] as? String ?? "Unknown"
                        case .militaryID:
                            title = name["Full name"] as? String ?? "Unknown"
                        case .vzrInsurance:
                            title = name["Full name"] as? String ?? "Unknown"
                        }
                        self.documents.append(Document(id: id, type: type, title: title))
                        self.documentsCollectionView.reloadData()
                    }
                }
            }
        }) { error in
          print(error.localizedDescription)
        }
        
        documentsCollectionView.delegate = self
        documentsCollectionView.dataSource = self
        documentsCollectionView.register(UINib(nibName: "DocumentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DocumentCollectionViewCell")
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

extension HomeViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredDocuments = documents.filter { document in
            let type = Document.typeToString(type: document.type)
            return type.lowercased().contains(text.lowercased())
        }
        documentsCollectionView.reloadData()
    }
}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            return filteredDocuments.count
        } else {
            return (documents.count + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            let cell = documentsCollectionView.dequeueReusableCell(withReuseIdentifier: "DocumentCollectionViewCell", for: indexPath) as! DocumentCollectionViewCell
            
            setUpCell(for: cell, at: indexPath, searchIsActive: true)
            
            return cell
        } else {
            if indexPath.row == 0 {
                return documentsCollectionView.dequeueReusableCell(withReuseIdentifier: "AddDocumentCollectionViewCell", for: indexPath) as! AddDocumentCollectionViewCell
            } else {
                let cell = documentsCollectionView.dequeueReusableCell(withReuseIdentifier: "DocumentCollectionViewCell", for: indexPath) as! DocumentCollectionViewCell
                
                setUpCell(for: cell, at: indexPath, searchIsActive: false)
                
                return cell
            }
        }
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
        return CGSize(width: (collectionView.bounds.width - 48) / 2, height: (collectionView.bounds.width - 48) / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            //...
        } else {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "HomeToNewDocument", sender: self)
            } else {
                //...
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            return setUpContextMenu(for: indexPath, searchIsActive: true)
        } else {
            if indexPath.row == 0 {
                return nil
            } else {
                return setUpContextMenu(for: indexPath, searchIsActive: false)
            }
        }
    }
    
    func setUpCell(for cell: DocumentCollectionViewCell, at indexPath: IndexPath, searchIsActive: Bool) {
        
        var document: Document?
        
        if searchIsActive {
            document = filteredDocuments[indexPath.row]
        } else {
            document = documents[indexPath.row - 1]
        }
        
        cell.titleLabel.text = Document.typeToString(type: document!.type)
        cell.subtitleLabel.text = document!.title
        
        switch document!.type {
        case .nationalPassport:
            cell.background.backgroundColor = UIColor(named: "NationalPassportColor")
            cell.documentImageView.image = UIImage(named: "Passport")
        case .internationalPassport:
            cell.background.backgroundColor = UIColor(named: "InternationalPassportColor")
            cell.documentImageView.image = UIImage(named: "Passport")
        case .birthCertificate:
            cell.background.backgroundColor = UIColor(named: "BirthCertificateColor")
            cell.documentImageView.image = UIImage(named: "BirthCertificate")
        case .foreignDocument:
            cell.background.backgroundColor = UIColor(named: "ForeignDocumentColor")
            cell.documentImageView.image = UIImage(named: "ForeignDocument")
        case .snils:
            cell.background.backgroundColor = UIColor(named: "SNILSColor")
            cell.documentImageView.image = UIImage(named: "SNILS")
        case .inn:
            cell.background.backgroundColor = UIColor(named: "INNColor")
            cell.documentImageView.image = UIImage(named: "INN")
        case .oms:
            cell.background.backgroundColor = UIColor(named: "OMSColor")
            cell.documentImageView.image = UIImage(named: "OMS")
        case .driversLicense:
            cell.background.backgroundColor = UIColor(named: "VehicleColor")
            cell.documentImageView.image = UIImage(named: "DriversLicense")
        case .vehicleRegID:
            cell.background.backgroundColor = UIColor(named: "VehicleColor")
            cell.documentImageView.image = UIImage(named: "VehicleDocument")
        case .vehiclePassport:
            cell.background.backgroundColor = UIColor(named: "VehicleColor")
            cell.documentImageView.image = UIImage(named: "VehicleDocument")
        case .osago:
            cell.background.backgroundColor = UIColor(named: "VehicleColor")
            cell.documentImageView.image = UIImage(named: "VehicleDocument")
        case .casco:
            cell.background.backgroundColor = UIColor(named: "VehicleColor")
            cell.documentImageView.image = UIImage(named: "VehicleDocument")
        case .militaryID:
            cell.background.backgroundColor = UIColor(named: "MilitaryIDColor")
            cell.documentImageView.image = UIImage(named: "MilitaryID")
        case .vzrInsurance:
            cell.background.backgroundColor = UIColor(named: "VZRInsuranceColor")
            cell.documentImageView.image = UIImage(named: "VZRInsurance")
        }
    }
    
    func setUpContextMenu(for indexPath: IndexPath, searchIsActive: Bool) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                
                let text = "Download the CloudDocs app to keep all your documents on your phone! Download now."
                
                let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                
                activityViewController.popoverPresentationController?.sourceView = self.view
                
                activityViewController.excludedActivityTypes = [
                    .airDrop,
                    .assignToContact,
                    .message,
                    .mail,
                    .copyToPasteboard,
                ]
                
                self.present(activityViewController, animated: true, completion: nil)
            }
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                
                if searchIsActive {
                    self.ref.child("users").child(self.user!.uid).child("documents").child(self.filteredDocuments[indexPath.row].id).removeValue()
                    self.filteredDocuments.remove(at: indexPath.row)
                    self.documentsCollectionView.reloadData()
                } else {
                    self.ref.child("users").child(self.user!.uid).child("documents").child(self.documents[indexPath.row - 1].id).removeValue()
                    self.documents.remove(at: indexPath.row - 1)
                    self.documentsCollectionView.reloadData()
                }
                SPAlert.present(title: "Deleted Document", preset: .done)
            }

            return UIMenu(title: "", children: [share, delete])
        }
    }
}