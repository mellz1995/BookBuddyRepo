//
//  SearchUsersViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/27/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

var userNameSearchResultsArray = Array<AnyObject>()

var userInformationArray = Array<Array<AnyObject>>()
var individualUserArray = Array<AnyObject>()
var searcedUserLibraryArray = Array<Array<AnyObject>>()

class SearchUsersViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        userInformationArray.removeAll()
        searcedUserLibraryArray.removeAll()
        individualUserArray.removeAll()
        print("Arrays cleared!")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButtonOutlet: UIButton!
    @IBAction func searchButtonAction(_ sender: UIButton) {
        self.dismissKeyboard()
        
        
        let query = PFUser.query()
        query?.findObjectsInBackground { (objects, error) in
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        // If the user's username matches the search value append it to the array
                        if (user.username?.contains(self.searchTextField.text!))!{
                            self.appendArray(user.username!)
                            print("Username is \(user.username!)")
                            individualUserArray.append(user.username as AnyObject)
                            if let userPicture = user.object(forKey: "profilePic")! as? PFFile {
                                userPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                                    let image = UIImage(data: imageData!)
                                    if image != nil {
                                        // Append the image to index 1
                                        print("An Image was found! Adding it to the array!")
                                        individualUserArray.append(image!)
                                        
                                        self.printOutSearchResults()
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
                                        
                                        
                                        // Send the user back to the search user's table view if we found a match
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let view = storyboard.instantiateViewController(withIdentifier: "InitialSearchUsers")
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        appDelegate.window?.rootViewController = view
                                    }
                                })
                            }
                        } else {
                            let alert = UIAlertController(title: "No resutls", message: "Your search of '\(self.searchTextField.text!)' did not return any results.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            }))
                        }
                    }
                }
            }
        }
    }
    
    func appendArray(_ username: String){
        userNameSearchResultsArray.append(username as AnyObject)
    }
    
    func printOutSearchResults(){
        print("The search array returned results: \(userNameSearchResultsArray)")
    }

    
    @IBOutlet weak var resultsTextView: UITextView!
    @IBOutlet weak var userImageView: UIImageView!
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
