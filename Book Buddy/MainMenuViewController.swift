//
//  MainMenuViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/12/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.current() != nil{
            navigationBar.title = PFUser.current()!.username
            navigationBar.backBarButtonItem?.title = PFUser.current()!.username
        }
        
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
        PFUser.logOut()
        
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
