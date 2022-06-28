import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SPAlert

class HomeViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    var imagePicker = UIImagePickerController()
    
    var accountButton: ImageBarButton!
    
    var documents = [Document]()
    var filteredDocuments = [Document]()
    
    var documentID = ""
    
    @IBOutlet weak var documentsCollectionView: UICollectionView!
    
    override func viewDidAppear(_ animated: Bool) {
        documentsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CloudDocs"
        navigationController!.navigationBar.prefersLargeTitles = true
        searchController.searchBar.tintColor = UIColor(named: "AccentColor")
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        user = Auth.auth().currentUser
        
        if user!.photoURL != nil  {
            accountButton = ImageBarButton(withUrl: user!.photoURL)
        } else {
            accountButton = ImageBarButton(withImage: UIImage(named: "Account"))
        }
        
        accountButton.button.addTarget(self, action: #selector(accountPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [accountButton.load()]
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
    }
    
    @objc func reload(notification: NSNotification) {
        documentsCollectionView.reloadData()
    }
    
    @objc func accountPressed() {
        let alert = UIAlertController(title: user!.displayName, message: user!.email, preferredStyle: .actionSheet)

        alert.view.tintColor = UIColor(named: "AccentColor")
        
        let uploadPhoto = UIAlertAction(title: "Upload Photo", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true)
            }
        }

        let signOut = UIAlertAction(title: "Sign Out", style: .default) { action in
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "HomeToWelcome", sender: self)
                UserDefaults.standard.removeObject(forKey: "passcode")
            } catch {
                print(error)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            alert.self.dismiss(animated: true)
        }

        alert.addAction(uploadPhoto)
        alert.addAction(signOut)
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToDocument" {
            let documentViewController = segue.destination as! DocumentViewController
            documentViewController.id = documentID
        }
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
            documentID = filteredDocuments[indexPath.row].id
            performSegue(withIdentifier: "HomeToDocument", sender: self)
        } else {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "HomeToNewDocument", sender: self)
            } else {
                documentID = documents[indexPath.row - 1].id
                performSegue(withIdentifier: "HomeToDocument", sender: self)
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
                
                var imageRef: StorageReference!
                
                if searchIsActive {
                    imageRef = self.storageRef.child("\(self.user!.uid)/documents/\(self.filteredDocuments[indexPath.row].id).png")
                } else {
                    imageRef = self.storageRef.child("\(self.user!.uid)/documents/\(self.documents[indexPath.row - 1].id).png")
                }
                
                imageRef.getData(maxSize: 50 * 1024 * 1024) { data, error in
                  if let error = error {
                      print(error)
                  } else {
                      if let image = UIImage(data: data!) {
                          let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                          
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
                  }
                }
            }
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                
                if searchIsActive {
                    self.ref.child("users").child(self.user!.uid).child("documents").child(self.filteredDocuments[indexPath.row].id).removeValue()
                    self.storageRef!.child("\(self.user!.uid)/documents/\(self.filteredDocuments[indexPath.row].id).png").delete { _ in }
                    self.filteredDocuments.remove(at: indexPath.row)
                    self.documentsCollectionView.reloadData()
                } else {
                    self.ref.child("users").child(self.user!.uid).child("documents").child(self.documents[indexPath.row - 1].id).removeValue()
                    self.storageRef!.child("\(self.user!.uid)/documents/\(self.documents[indexPath.row - 1].id).png").delete { _ in }
                    self.documents.remove(at: indexPath.row - 1)
                    self.documentsCollectionView.reloadData()
                }
                SPAlert.present(title: "Deleted Document", preset: .done)
            }

            return UIMenu(title: "", children: [share, delete])
        }
    }
}

extension HomeViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in })
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        accountButton.imageView.image = image
        
        let accountRef = storageRef!.child("\(user!.uid)/account.png")
        
        let accountUpload = accountRef.putData(image.pngData()!, metadata: nil) { (metadata, error) in
            accountRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }

                let changeRequest = self.user!.createProfileChangeRequest()
                changeRequest.photoURL = downloadURL
                changeRequest.commitChanges()
            }
        }
        
        accountUpload.resume()
    }
}
