import UIKit

class AddPhotoButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var addPhotoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addPhotoButton.setTitle("Add photo of document".localized(), for: .normal)
        addPhotoButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
