import UIKit
import AVFoundation

class ScannerViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var path = ""

    @IBOutlet weak var qrCodeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = qrCodeView.layer.bounds
            videoPreviewLayer?.cornerRadius = 10
            qrCodeView.layer.addSublayer(videoPreviewLayer!)
            qrCodeView.layer.cornerRadius = 10
            
            captureSession.startRunning()
        } catch {
            print(error)
            dismiss(animated: true)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScannerToShared" {
            let sharedViewController = segue.destination as! SharedViewController
            sharedViewController.path = path
        }
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count != 0 {
            let metadata = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadata.type == AVMetadataObject.ObjectType.qr {
                if metadata.stringValue != nil {
                    path = metadata.stringValue!
                    captureSession.stopRunning()
                    performSegue(withIdentifier: "ScannerToShared", sender: self)
                }
                captureSession.stopRunning()
            }
            captureSession.stopRunning()
        }
    }
}
