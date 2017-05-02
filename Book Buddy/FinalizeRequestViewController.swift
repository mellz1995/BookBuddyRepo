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
    
    var activityIndicator = UIActivityIndicatorView()
    var finalRequestedBookArray = Array<AnyObject>()
    var requestedUserReceivedReqeuests = Array<Array<AnyObject>>()
    var originalUsername = PFUser.current()!.username
    var originalUserPassword = PFUser.current()?.object(forKey: "recoveryPassword")
    var secondUser = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshServerData()
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
                    
                    // Start the activity spinner
                    self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                    self.activityIndicator.center = self.view.center
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                    self.view.addSubview(self.activityIndicator)
                    self.activityIndicator.startAnimating()
                    UIApplication.shared.beginIgnoringInteractionEvents()
                
                    // add the book to the current user's requested library
                    self.finalRequestedBookArray = requestedBookArray as Array<AnyObject>
                    
                    // Format the data
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd, yyyy"
                    let selectedDate = dateFormatter.string(from: self.dataPicker.date)
                    print("The selected date is ", selectedDate)
                    
                    // Add the date to index 11 of the finalRequestedBookArray
                    self.finalRequestedBookArray.append(selectedDate as AnyObject)
                    
                    self.finalRequestedBookArray[6] = "Requested" as AnyObject
            
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
                                       
                                        
                                        let wait1 = DispatchTime.now() + 1.0
                                            DispatchQueue.main.asyncAfter(deadline: wait1) {
                                            // Logout the initial current user
                                            PFUser.logOut()
                                            print("The initial user (\(self.originalUsername!)) was logged out...")
                                               
                                                let wait = DispatchTime.now() + 0.5
                                                DispatchQueue.main.asyncAfter(deadline: wait) {
                                                    // Login the user that the initial current user is requesting the book from
                                                    PFUser.logInWithUsername(inBackground: user.username!, password: user.object(forKey: "recoveryPassword") as! String, block: { (user, error) in
                                                        if error != nil {
                                                            
                                                        } else {
                                                            print("Success! Second user (\(PFUser.current()!.username!)) is logged in.")
                                                            self.secondUser = PFUser.current()!.username!
                                                            
                                                            // Append the user who's requesting to borrow the book at index 12
                                                            self.finalRequestedBookArray.append(self.originalUsername! as AnyObject)
                                                            
                                                            self.requestedUserReceivedReqeuests = PFUser.current()!.object(forKey: "receivedRequestsLibrary") as! Array<Array<AnyObject>>
                                                            self.requestedUserReceivedReqeuests.append(self.finalRequestedBookArray)
                                                            
                                                            // Set the requested book to the requested user's received requests library
                                                            GUSUerLibrary(self.finalRequestedBookArray, "receivedRequestsLibrary", "didReceiveFirstRequest")
                                                            
                                                            let wait = DispatchTime.now() + 1.0
                                                            DispatchQueue.main.asyncAfter(deadline: wait) {
                                                                PFUser.logOut()
                                                                print("The second user (\(self.secondUser)) is logged out..")
                                                                
                                                                let wait3 = DispatchTime.now() + 1.5
                                                                DispatchQueue.main.asyncAfter(deadline: wait3){
                                                                    print("Attempting to log back in the original current user")
                                                                    PFUser.logInWithUsername(inBackground: self.originalUsername!, password: self.originalUserPassword as! String, block: { (user, error) in
                                                                        if error != nil {
                                                                        
                                                                        } else {
                                                                            print("Success! The original user (\(PFUser.current()!.username!)) is logged back in.")
                                                                            
                                                                            print("The process is complete!")
                                                                            self.activityIndicator.stopAnimating()
                                                                            UIApplication.shared.endIgnoringInteractionEvents()
                                                                            
                                                                            let successAlert = UIAlertController(title: "Complete!", message: "The request was successfully made!", preferredStyle: UIAlertControllerStyle.alert)
                                                                            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                                                            }))
                                                                            self.present(successAlert, animated: true, completion: nil)
                                                                        }
                                                                    })
                                                                }
                                                            }
                                                        }
                                                        
                                                    })
                                                }
                                        }
                                        
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
