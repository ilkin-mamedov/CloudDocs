import UIKit

class ScanDocumentTableViewCell: UITableViewCell {

    @IBOutlet weak var scanDocumentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scanDocumentButton.setTitle("Add scan of document".localized(), for: .normal)
        scanDocumentButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
