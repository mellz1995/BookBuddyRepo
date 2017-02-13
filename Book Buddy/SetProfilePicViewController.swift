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
    
    let setProfilePic = false

    override func viewDidLoad() {
        super.viewDidLoad()
    // Set the picture to the default smily
        profilePicView.image = #imageLiteral(resourceName: "smily")
        
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
        profilePicView.image = #imageLiteral(resourceName: "smily")
        updateBoolStats(false, "didSetProfilePic")
        skipButtonOutlet.setTitle("Skip", for: [])
    }
    
    @IBAction func importPhotoButtonAction(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicView.image = image
            let uploadableImage = PFFile(data: UIImageJPEGRepresentation(image, 1.0)!)
            updateBoolStats(true, "didSetProfilePic")
            updateProfilePic(uploadableImage!, "profilePic")
        } else {
            self.displayAlert("Error processing image file", "There was an error processing the image file. Please try again.", "Ok")
        }
        self.dismiss(animated: true) {
            self.skipButtonOutlet.setTitle("Done", for: [])
        }
    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        
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
