import UIKit

class NewDocumentViewController: UIViewController {
    
    var homeViewController: HomeViewController?
    
    let searchController = UISearchController(searchResultsController: nil)

    let newDocuments = [
        NewDocument(type: .nationalPassport, image: UIImage(named: "Passport"), title: "National Passport"),
        NewDocument(type: .internationalPassport, image: UIImage(named: "Passport"), title: "International Passport"),
        NewDocument(type: .birthCertificate, image: UIImage(named: "BirthCertificate"), title: "Birth Certificate"),
        NewDocument(type: .foreignDocument, image: UIImage(named: "ForeignDocument"), title: "Foreign Document"),
        NewDocument(type: .snils, image: UIImage(named: "SNILS"), title: "SNILS"),
        NewDocument(type: .inn, image: UIImage(named: "INN"), title: "INN"),
        NewDocument(type: .oms, image: UIImage(named: "OMS"), title: "OMS"),
        NewDocument(type: .driversLicense, image: UIImage(named: "DriversLicense"), title: "Drivers License"),
        NewDocument(type: .vehicleRegID, image: UIImage(named: "VehicleDocument"), title: "Vehicle Reg ID"),
        NewDocument(type: .vehiclePassport, image: UIImage(named: "VehicleDocument"), title: "Vehicle Passport"),
        NewDocument(type: .osago, image: UIImage(named: "VehicleDocument"), title: "OSAGO"),
        NewDocument(type: .casco, image: UIImage(named: "VehicleDocument"), title: "CASCO"),
        NewDocument(type: .militaryID, image: UIImage(named: "MilitaryID"), title: "Military ID"),
        NewDocument(type: .vzrInsurance, image: UIImage(named: "VZRInsurance"), title: "VZR Insurance")
    ]
    
    var filteredNewDocuments = [NewDocument]()
    
    var selectedType: DocumentType?
    
    @IBOutlet weak var newDocumentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Document"
        searchController.searchBar.tintColor = UIColor(named: "AccentColor")
        searchController.searchResultsUpdater = self
                searchController.delegate = self
        navigationItem.searchController = searchController
        
        newDocumentTableView.delegate = self
        newDocumentTableView.dataSource = self
        newDocumentTableView.register(UINib(nibName: "NewDocumentTableViewCell", bundle: nil), forCellReuseIdentifier: "NewDocumentTableViewCell")
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewDocumentToAddDocument" {
            let addDocumentViewController = segue.destination as! AddDocumentViewController
            addDocumentViewController.type = selectedType!
        }
    }
}

extension NewDocumentViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredNewDocuments = newDocuments.filter { newDocument in
            return newDocument.title.lowercased().contains(text.lowercased())
        }
        newDocumentTableView.reloadData()
    }
}

extension NewDocumentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            return filteredNewDocuments.count
        } else {
            return newDocuments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newDocumentTableView.dequeueReusableCell(withIdentifier: "NewDocumentTableViewCell", for: indexPath) as! NewDocumentTableViewCell
        
        let newDocument: NewDocument?
        
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            newDocument = filteredNewDocuments[indexPath.row]
        } else {
            newDocument = newDocuments[indexPath.row]
        }
        
        
        switch newDocument!.type {
        case .nationalPassport:
            cell.documentImageView.backgroundColor = UIColor(named: "NationalPassportColor")
        case .internationalPassport:
            cell.documentImageView.backgroundColor = UIColor(named: "InternationalPassportColor")
        case .birthCertificate:
            cell.documentImageView.backgroundColor = UIColor(named: "BirthCertificateColor")
        case .foreignDocument:
            cell.documentImageView.backgroundColor = UIColor(named: "ForeignDocumentColor")
        case .snils:
            cell.documentImageView.backgroundColor = UIColor(named: "SNILSColor")
        case .inn:
            cell.documentImageView.backgroundColor = UIColor(named: "INNColor")
        case .oms:
            cell.documentImageView.backgroundColor = UIColor(named: "OMSColor")
        case .driversLicense:
            cell.documentImageView.backgroundColor = UIColor(named: "VehicleColor")
        case .vehicleRegID:
            cell.documentImageView.backgroundColor = UIColor(named: "VehicleColor")
        case .vehiclePassport:
            cell.documentImageView.backgroundColor = UIColor(named: "VehicleColor")
        case .osago:
            cell.documentImageView.backgroundColor = UIColor(named: "VehicleColor")
        case .casco:
            cell.documentImageView.backgroundColor = UIColor(named: "VehicleColor")
        case .militaryID:
            cell.documentImageView.backgroundColor = UIColor(named: "MilitaryIDColor")
        case .vzrInsurance:
            cell.documentImageView.backgroundColor = UIColor(named: "VZRInsuranceColor")
        }
        
        cell.documentImageView.image = newDocument!.image
        cell.titleLabel.text = newDocument!.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            selectedType = filteredNewDocuments[indexPath.row].type
        } else {
            selectedType = newDocuments[indexPath.row].type
        }
        newDocumentTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "NewDocumentToAddDocument", sender: self)
    }
}
