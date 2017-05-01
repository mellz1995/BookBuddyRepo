//
//  MyQRViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 5/1/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class MyQRViewController: UIViewController {
    
    var username = PFUser.current()!.username
    var whatsThis = false
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLabel.text = "\(username!)'s QR Code"
        qrImage.image = generateQR(username!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var whatsThisOutlet: UIButton!
    @IBAction func whatsThisAction(_ sender: UIButton) {
        if whatsThis == false {
            whatsThisOutlet.setImage(#imageLiteral(resourceName: "GREAT"), for: [])
            textViewOutlet.text = "A QR code is a machine-readable code consisting of an array of black and white squares, typically used for storing URLs or other information for reading by the camera on a smartphone."
            whatsThis = true
        } else {
            whatsThisOutlet.setImage(#imageLiteral(resourceName: "RegisterButton Copy"), for: [])
            textViewOutlet.text = "Tell your friend to open their camera and scan your QR code to bring up your profile!"
            whatsThis = false
        }
    }
    
    @IBOutlet weak var textViewOutlet: UITextView!
    
    func generateQR(_ string: String) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        let output = filter?.outputImage?.applying(transform)
        if output != nil {
            return UIImage(ciImage: output!)
        }
        return UIImage()
    }

}
