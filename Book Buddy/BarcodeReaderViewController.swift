//  BarcodeReaderViewController.swift
//  Book Buddy
//
//  Created by Melvin Corners on 2/1/17.
//  Copyright © 2017 Melvin Corners. All rights reserved.
//

import UIKit
import AVFoundation

var scannedBarcode = ""
var scanned = false
import Parse

class BarcodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    @IBOutlet weak var backButtonOutlet: UIButton!
    
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the message label and top bar to the front
            //view.bringSubview(toFront: messageLabel)
            //view.bringSubview(toFront: topbar)
            view.bringSubview(toFront: backButtonOutlet)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    func displayAlert(_ title: String, _ message: String, _ confirmation: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: confirmation, style: .default, handler: { (action) in
            if comingFromSearch == true {
                let query = PFUser.query()
                query?.findObjectsInBackground { (objects, error) in
                    if let users = objects {
                        for object in users {
                            if let user = object as? PFUser {
                                // Set the contents of the search field to lowercase
                                let lowerCaseSearch = scannedBarcode
                                
                                // Delete the space at the end
                                let noSpaces = lowerCaseSearch.replacingOccurrences(of: " ", with: "")
                                
                                // If the user's username matches the search value append it to the array
                                if (user.username?.contains(noSpaces))!{
                                    print("Username is \(user.username!)")
                                    individualUserArray.append(user.username as AnyObject)
                                    if let userPicture = user.object(forKey: "profilePic")! as? PFFile {
                                        userPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                                            let image = UIImage(data: imageData!)
                                            if image != nil {
                                                // Append the image to index 1
                                                print("An Image was found! Adding it to the array!")
                                                individualUserArray.append(image!)
                                                
                                                // Append the user's object ID
                                                individualUserArray.append(user.objectId as AnyObject)
                                                
                                                
                                                var didSaveFirst = false
                                                
                                                if user.object(forKey: "didSaveFirstBook") as! Bool == false {
                                                    didSaveFirst = false
                                                } else {
                                                    didSaveFirst = true
                                                }
                                                
                                                // Append the user's DidAddFirstBook to array
                                                individualUserArray.append(didSaveFirst as AnyObject)
                                                
                                                // Append all of the user's information into the full user's array
                                                userInformationArray.append(individualUserArray)
                                                print("UserinformationArray is : \(userInformationArray)")
                                                
                                                // Check to see if the user has a library
                                                if user.value(forKey: "didSaveFirstBook") as! Bool == false {
                                                    print("\(user.username!)'s library is empty")
                                                } else {
                                                    print("\(user.username!)'s library is not empty. Appending to array...")
                                                    searcedUserLibraryArray = user.value(forKey: "library") as! Array<Array<AnyObject>>
                                                    print()
                                                    print("\(user.username!)'s library has \(searcedUserLibraryArray.count) book(s)")
                                                    print("\(user.username!)'s library is \(searcedUserLibraryArray)")
                                                }
                                                
                                                if comingFromSearch == true {
                                                    let this = SearchedUserInformationViewController()
                                                    
                                                    this.userInforomation = userInformationArray[0]
                                                }
                                                
                                                
                                                // Send the user back to the search user's table view if we found a match
                                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                                let view = storyboard.instantiateViewController(withIdentifier: "SearchedUsersProfile")
                                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                                appDelegate.window?.rootViewController = view
                                            }
                                        })
                                    }
                                } else {
                                    
                                }
                            }
                        }
                    }
                }
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let view = storyboard.instantiateViewController(withIdentifier: "NewBook")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = view
                self.captureSession?.stopRunning()
                searchScannedResult(scannedBarcode)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR/barcode is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                //messageLabel.text = metadataObj.stringValue
                scanned = true
                print("Scanned was just set to true")
                print(metadataObj.stringValue)
                scannedBarcode = metadataObj.stringValue
                captureSession?.stopRunning()
                
                displayAlert("Barcode Found!!", metadataObj.stringValue, "Let's searh it!")
                backButtonOutlet.alpha = 0
                backButtonOutlet.isEnabled = false
                
                
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        captureSession?.stopRunning()
    }
    
}
