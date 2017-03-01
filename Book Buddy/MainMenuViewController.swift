//
//  MainMenuViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/12/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class MainMenuViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var activityIndicator = UIActivityIndicatorView()
    
    var userLibrary = [[String]]()
    var book = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This check is for testing purposes when I don't have a logged in user
        if PFUser.current() != nil{
            navigationBar.title = PFUser.current()!.username
            navigationBar.backBarButtonItem?.title = PFUser.current()!.username
        
        
            if PFUser.current()!.object(forKey: "didSetProfilePic") as! Bool == false{
            
            } else {
                if let userPicture = PFUser.current()!.object(forKey: "profilePic")! as? PFFile {
                    userPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                        let image = UIImage(data: imageData!)
                        if image != nil {
                            self.profilePicture.image = image
                        }
                    })
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Override function that rounds the profile picture
    override func viewDidLayoutSubviews() {
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
    }
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var logoutButtonOutlet: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    
    
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Logut?", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            PFUser.logOut()
            // Send the user to the main menu
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewController(withIdentifier: "LoginScreen")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = view
        }))
        
        alert.addAction(UIAlertAction(title: "No, cancel", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeProfilePicButtonAction(_ sender: UIButton) {
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
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Start animator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        profilePicture.alpha = 0
        
        
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
        
        self.dismiss(animated: true, completion: nil)
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
