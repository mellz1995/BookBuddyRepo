//
//  SearchedUserInformationViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 3/1/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

var currentUser = ""

class SearchedUserInformationViewController: UIViewController {
    
    var userLibrary = Array<Array<AnyObject>>()
    public var userInforomation = Array<AnyObject>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setEverythingUp()
    }
    
    // Override function that rounds the profile picture
    override func viewDidLayoutSubviews() {
        userProfilePic.layer.cornerRadius = userProfilePic.frame.size.width/2
        userProfilePic.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setEverythingUp(){
        usernameLabel.text = userInforomation[0] as? String
        currentUser = (userInforomation[0] as? String)!
        userProfilePic.image = userInforomation[1] as? UIImage
        libraryCountLabel.text = "\(searcedUserLibraryArray.count) book(s) in library."
        viewUserLibraryButtonOutlet.setTitle("View \(userInforomation[0])'s library", for: [])
        
        // Disable the button to view the user's library if the count is zero. This will avoid the stupid nil error
        if searcedUserLibraryArray.count == 0 {
            viewUserLibraryButtonOutlet.isEnabled = false
        }
    }
    
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var libraryCountLabel: UILabel!
    @IBOutlet weak var requestToLinkButtonOutlet: UIButton!
    @IBOutlet weak var viewUserLibraryButtonOutlet: UIButton!
    
    @IBAction func requestToLinkButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add \(userInforomation[0]) as a friend?", message: "This will add this user as a friend.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            var currentFriends = PFUser.current()!.object(forKey: "friends") as! Array<Array<Any>>
            
            // Add the user as a friend for testing purposes now!
            var addFriendArray = Array<AnyObject>()
            
            // Get the userID of the user and append it to the array at index 0, username at index 1, and user's profile picture at index 2
            let query = PFUser.query()
            query?.findObjectsInBackground(block: { (objects, error) in
                
                if error != nil {
                    let alert2 = UIAlertController(title: "Error", message: error as! String?, preferredStyle: UIAlertControllerStyle.alert)
                    alert2.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    }))
                    self.present(alert2, animated: true, completion: nil)
                } else {
                    
                    if PFUser.current()!.object(forKey: "didAddFirstFrend") as! Bool == false {
                        currentFriends.removeAll()
                        updateBoolStats(true, "didAddFirstFrend")
                    }
                    
                    if let users = objects {
                        for object in users {
                            if let user = object as? PFUser {
                                if user.username! == self.userInforomation[0] as! String {
                                    addFriendArray.append(user.objectId! as AnyObject)
                                    addFriendArray.append(user.username! as AnyObject)
                                    
                                    // Get the user's profile picture and append it as well
                                    if let userPicture = user.object(forKey: "profilePic")! as? PFFile {
                                        userPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                                            let image = UIImage(data: imageData!)
                                            if image != nil {
                                                // Append the image to index 2
                                                addFriendArray.append(image!)
                                                currentFriends.append(addFriendArray)
                                                print("addFriendArray is \(addFriendArray)")
                                                // Save the new friend online
                                                updateArray(currentFriends as Array<Array<AnyObject>>, "friends")
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "No, don't add", style: .default, handler: { (action) in
          
        }))
        self.present(alert, animated: true, completion: nil)
        
        
        
        
        
        
        
        
        
        
        
    
    }
    
    @IBAction func viewUserLibraryButtonAction(_ sender: UIButton) {
        
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
