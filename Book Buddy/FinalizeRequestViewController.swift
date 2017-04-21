//
//  FinalizeRequestViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 4/21/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class FinalizeRequestViewController: UIViewController {
    
    var finalRequestedBookArray = Array<AnyObject>()
    var requestedUserReceivedReqeuests = Array<Array<AnyObject>>()
    var originalUsername = PFUser.current()!.username
    var originalUserPassword = PFUser.current()?.object(forKey: "recoveryPassword")

    override func viewDidLoad() {
        super.viewDidLoad()

        setEverythingUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var booktitle: UILabel!
    @IBOutlet weak var requestingFromUsername: UILabel!
    @IBOutlet weak var dataPicker: UIDatePicker!
    @IBAction func datePickerAction(_ sender: UIDatePicker) {
    }
    
    @IBOutlet weak var finalizeRequestOutlet: UIButton!
    @IBAction func finalizeRequestAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Finalize Request?", message: "Request to borrow '\(requestedBookArray[0])'?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                    // add the book to the current user's requested library
                    self.finalRequestedBookArray = requestedBookArray as Array<AnyObject>
                    
                    // Format the data
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    let selectedDate = dateFormatter.string(from: self.dataPicker.date)
                    print("The selected date is ", selectedDate)
                    
                    // Add the date to index 11 of the finalRequestedBookArray
                    self.finalRequestedBookArray.append(selectedDate as AnyObject)
            
                    // Add the requested book to the user's requested library
                    GUSUerLibrary(self.finalRequestedBookArray as [AnyObject], "requestedLibrary", "didRequestFirstBook")
                    
                    print("The requested book is: \(self.finalRequestedBookArray)")
                    
                    
                    // Add the book to the requested user's received requests array
                    let query = PFUser.query()
                    query?.findObjectsInBackground { (objects, error) in
                        if let users = objects {
                            for object in users {
                                if let user = object as? PFUser {
                                    print("finalRequestedBookArray at index 9 is \(self.finalRequestedBookArray[9])")
                                    if (user.username?.contains(self.finalRequestedBookArray[9] as! String))!{
                                       self.requestedUserReceivedReqeuests = user.object(forKey: "receivedRequestsLibrary") as! Array<Array<AnyObject>>
                                        self.requestedUserReceivedReqeuests.append(self.finalRequestedBookArray)
                                        
                                        let wait1 = DispatchTime.now() + 3.0
                                            DispatchQueue.main.asyncAfter(deadline: wait1) {
                                            // Logout the initial current user
                                            PFUser.logOut()
                                            print("The initial user was logged out...")
                                        }
                                        
                                        let wait = DispatchTime.now() + 5.0
                                        DispatchQueue.main.asyncAfter(deadline: wait) {
                                            // Login the user that the initial current user is requesting the book from
                                            PFUser.logInWithUsername(inBackground: user.username!, password: user.object(forKey: "recoveryPassword") as! String, block: { (user, error) in
                                                if error != nil {
                                                    
                                                } else {
                                                    print("Success! The second user is logged in.")
                                                    
                                                    // Set the requested book to the requested user's received requests library
                                                    GUSUerLibrary(self.finalRequestedBookArray, "receivedRequestsLibrary", "didReceiveFirstRequest")
                                                    
                                                    // Log out the requested user's account
                                                    PFUser.logOut()
                                                    print("The second user is logged out..")
                                                    
                                                    let wait = DispatchTime.now() + 3.5
                                                    DispatchQueue.main.asyncAfter(deadline: wait) {
                                                        print("Attempting to log back in the original current user")
                                                        PFUser.logInWithUsername(inBackground: self.originalUsername!, password: self.originalUserPassword as! String, block: { (user, error) in
                                                            if error != nil {
                                                            
                                                            } else {
                                                                print("Success! The original user is logged back in.")
                                                            }
                                                        })
                                                    }
                                                }
                                                
                                            })
                                            
                                        }
//                                        user.setValue(self.requestedUserReceivedReqeuests, forKey: "receivedRequestsLibrary")
//                                        user.saveInBackground(block: { (success, error) in
//                                            if error != nil {
//                                                print("Error with saving recieved")
//                                                // Clear the requestedBook array
//                                                requestedBookArray.removeAll()
//                                                self.finalRequestedBookArray.removeAll()
//                                                print("Requested Book Array Cleared!")
//                                            }
//                                            else {
//                                                print("Successfully saved received")
//                                            }
//                                        })
                                        
//                                        let addRequest = PFObject(className: "AddRequests")
//                                        addRequest["currentUser"] = ["__type": "Pointer", "className": "_User", "objectId": PFUser.current()?.objectId]
//                                        addRequest["requestedUser"] = ["__type": "Pointer", "className": "_User", "objectId": user.objectId!, "receivedRequestsLibrary": self.finalRequestedBookArray]
//                                        addRequest.saveInBackground { (success, error) -> Void in
//                                            if error != nil {
//                                                print(error!)
//                                            } else {
//                                                print("The request was successfully saved")
//                                            }
//                                        }
                                    } else {
                                        
                                    }
                                }
                            }
                        }
                    }
                    
            }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.finalRequestedBookArray.removeAll()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setEverythingUp(){
        
        dataPicker.datePickerMode = UIDatePickerMode.date
        
        // Set the image of the book
        if let bookPicture = requestedBookArray[7] as? PFFile {
            bookPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                let image = UIImage(data: imageData!)
                if image != nil {
                    self.bookImage.image = image
                }
            })
        }
        
        booktitle.text = requestedBookArray[0] as? String
        requestingFromUsername.text = requestedBookArray[9] as? String
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
