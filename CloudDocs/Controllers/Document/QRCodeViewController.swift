import UIKit
import FirebaseCore
import FirebaseAuth

class QRCodeViewController: UIViewController {
    
    var user: User?
    
    var path = ""

    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Auth.auth().currentUser
        
        qrCodeImageView.layer.cornerRadius = 10
        qrCodeImageView.layer.borderColor = UIColor.black.cgColor
        qrCodeImageView.layer.borderWidth = 1
        qrCodeImageView.image = generateQRCode(from: path)!
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}
