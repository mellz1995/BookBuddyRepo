//
//  SetProfilePicViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/10/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class SetProfilePicViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var setProfilePic = false

    override func viewDidLoad() {
        super.viewDidLoad()
    // Set the picture to the default smily
       // profilePicView.image = #imageLiteral(resourceName: "smily")
        clearButtonOutlet.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Override function that rounds the profile picture
    override func viewDidLayoutSubviews() {
        profilePicView.layer.cornerRadius = profilePicView.frame.size.width/2
        profilePicView.clipsToBounds = true
    }
    
    
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var skipButtonOutlet: UIButton!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var photoDescriptionTextView: UITextView!
    @IBOutlet weak var importPhotoButtonOutlet: UIButton!
    
    
    @IBAction func clearButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Clear photo?", message: "Do you want to clear this photo?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes, clear", style: .destructive, handler: { (action) in
            self.profilePicView.image = #imageLiteral(resourceName: "InitialSadBook")
            updateBoolStats(false, "didSetProfilePic")
            self.setProfilePic = false
            self.skipButtonOutlet.setImage(#imageLiteral(resourceName: "SkipButton"), for: [])
            self.clearButtonOutlet.isEnabled = false
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePickerController.allowsEditing = false
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func importPhotoButtonAction(_ sender: UIButton) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicView.image = image
            // Uncomment the next three lines when done with testing
            let uploadableImage = PFFile(data: UIImageJPEGRepresentation(image, 1.0)!)
            updateBoolStats(true, "didSetProfilePic")
            updateProfilePic(uploadableImage!, "profilePic")
            setProfilePic = true
        } else {
            self.displayAlert("Error processing image file", "There was an error processing the image file. Please try again.", "Ok")
        }
        self.dismiss(animated: true) {
            self.skipButtonOutlet.setImage(#imageLiteral(resourceName: "NextButton"), for: [])
            self.clearButtonOutlet.isEnabled = true
        }
    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        
        if setProfilePic == false {
            // Display alert and send the user to the main menu if they choose
            let alert = UIAlertController(title: "Sure?", message: "You can set a profile picture at any time from your profile", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                // Send the user to the main menu
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let view = storyboard.instantiateViewController(withIdentifier: "MainMenu")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = view
            }))
        
            alert.addAction(UIAlertAction(title: "No, cancel", style: .default, handler: { (action) in
            
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            // No alert needed for this. Just send them to the main menu
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewController(withIdentifier: "MainMenu")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = view
        }
    }
    
    func displayAlert(_ title: String, _ message: String, _ confirmation: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: confirmation, style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
