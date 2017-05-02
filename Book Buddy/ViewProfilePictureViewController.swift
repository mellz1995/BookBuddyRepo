//
//  ViewProfilePictureViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 4/5/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class ViewProfilePictureViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.current()!.object(forKey: "didSetProfilePic") as! Bool == false{
            // profilePictureOutlet.setImage(#imageLiteral(resourceName: "InitialSadBook"), for: [])
            profilePicture.image = #imageLiteral(resourceName: "InitialSadBook")
        } else {
            if let userPicture = PFUser.current()!.object(forKey: "profilePic")! as? PFFile {
                userPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                    let image = UIImage(data: imageData!)
                    if image != nil {
                        // self.profilePictureOutlet.setImage(image, for: [])
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
