//
//  ViewProfilePictureViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 4/5/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class ViewProfilePictureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var profilePictureLabel: UILabel!
    @IBOutlet weak var changeButtonOutlet: UIButton!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    var activityIndicator = UIActivityIndicatorView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.current()!.object(forKey: "didSetProfilePic") as! Bool == false{
            // profilePictureOutlet.setImage(#imageLiteral(resourceName: "InitialSadBook"), for: [])
            profilePicture.image = #imageLiteral(resourceName: "InitialSadBook")
            clearButtonOutlet.isEnabled = false
            clearButtonOutlet.alpha = 0.2
        } else {
            if let userPicture = PFUser.current()!.object(forKey: "profilePic")! as? PFFile {
                userPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                    let image = UIImage(data: imageData!)
                    if image != nil {
                        // self.profilePictureOutlet.setImage(image, for: [])
                        self.profilePicture.image = image
                        self.clearButtonOutlet.isEnabled = true
                        self.clearButtonOutlet.alpha = 1.0
                    }
                })
            }
        }
    }
    
    @IBAction func changeButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "From where?", message: "Take a picture or use one from your photo library?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
            imagePickerController.allowsEditing = false
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self 
            imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePickerController.allowsEditing = false
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clearButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Clear photo?", message: "Do you want to clear this photo?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes, clear", style: .destructive, handler: { (action) in
            self.profilePicture.image = #imageLiteral(resourceName: "InitialSadBook")
            updateBoolStats(false, "didSetProfilePic")
            self.clearButtonOutlet.isEnabled = false
            self.profilePictureLabel.text = "Image cleared."
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        if let image = info[UIImagePickerControllerOriginalImage] as! UIImage? {
            let imgageFile = PFFile(name: PFUser.current()!.username, data: UIImagePNGRepresentation(image)!)
            
            // Set the profile pic online
            PFUser.current()?.setValue(imgageFile, forKey: "profilePic")
            
            
            PFUser.current()?.saveInBackground(block: { (success, error) in
                if error != nil {
                    print("Error with saving proifile pic")
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.profilePicture.image = image
                    self.viewDidLoad()
                    self.activityIndicator.stopAnimating()
                }
                else {
                    self.profilePictureLabel.text = "Image is successfully saved!"
                    print("Successfully saved profile pic")
                    updateBoolStats(true, "didSetProfilePic")
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.activityIndicator.stopAnimating()
                }
            })
        } else {
            print("Error picking picture from camera roll, bro.")
            UIApplication.shared.endIgnoringInteractionEvents()
            activityIndicator.stopAnimating()
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var profilePicture: UIImageView!

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
