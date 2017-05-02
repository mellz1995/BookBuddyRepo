//
//  RequestedBookInformationViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 4/7/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

class RequestedBookInformationViewController: UIViewController {
    
    var activityIndicator = UIActivityIndicatorView()
    
    var currentRequestedLibrary = Array<Array<AnyObject>>()
    public var requestedBookInformation = Array<AnyObject>()
    
    var currentUsername = PFUser.current()!.username
    var currentUserPassword = PFUser.current()!.object(forKey: "recoveryPassword")
    var secondUser = ""
    var matchingTitle = ""
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbn10Label: UILabel!
    @IBOutlet weak var isbn13Label: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var cancelRequestOutlet: UIButton!
    @IBOutlet weak var requestedFromOutlet: UILabel!
    @IBOutlet var denyRequestOutlet: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setEverythingUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setEverythingUp(){
        currentRequestedLibrary = PFUser.current()!.object(forKey: "requestedLibrary") as! Array<Array<AnyObject>>
        
        if mode == "Received" {
            cancelRequestOutlet.setImage(#imageLiteral(resourceName: "ApproveRequestButton"), for: [])
            requestedFromOutlet.text = "Requested from \(requestedBookInformation[12]) until \(requestedBookInformation[11])."
        } else {
            requestedFromOutlet.text = "Requested from \(requestedBookInformation[12]) until \(requestedBookInformation[11])."
           cancelRequestOutlet.setImage(#imageLiteral(resourceName: "CancelRequestButton"), for: [])
        }
        
        // Set the labels
        titleLabel.text = requestedBookInformation[0] as? String
        authorLabel.text = requestedBookInformation[1] as? String
        isbn10Label.text = requestedBookInformation[2] as? String
        isbn13Label.text = requestedBookInformation[3] as? String
        publisherLabel.text = requestedBookInformation[4] as? String
        languageLabel.text = requestedBookInformation[5] as? String
        print("Book Id?: \(requestedBookInformation[10])")
        //bookIDLabel.text = "Book id?"
        
        // Set the image of the book
        if let bookPicture = requestedBookInformation[7] as? PFFile {
            bookPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                let image = UIImage(data: imageData!)
                if image != nil {
                    self.bookImage.image = image
                }
            })
        }
    }
    
    @IBAction func cancelRequestAction(_ sender: UIButton) {
        
        if mode == "Sent" {
            let alert = UIAlertController(title: "Cancel Request?", message: "Cancel request to borrow '\(self.requestedBookInformation[0])'?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                // Start the activity spinner
                self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                self.activityIndicator.center = self.view.center
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                self.view.addSubview(self.activityIndicator)
                self.activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                for i in 0..<self.currentRequestedLibrary.count{
                    // if the title of the book about to be deleted matches the title of the book in the user's array
                    if self.currentRequestedLibrary[i][0] as! String == self.requestedBookInformation[0] as! String {
                        // Remove the book from the current User's sent requests library
                        print("MATCH FOUND! \(self.currentRequestedLibrary[i][0])")
                        self.matchingTitle = self.currentRequestedLibrary[i][0] as! String
                        self.currentRequestedLibrary.remove(at: i)
                    }
                }
                
                // if the current user's requested library count is now 0, set the boolean back to false on the server
                if self.currentRequestedLibrary.count == 0 {
                    updateBoolStats(false, "didRequestFirstBook")
                    print("\(self.currentUsername!)'s sent request library is now empty.")
                }
            
                // update the deletion on the server
                updateArray(self.currentRequestedLibrary, "requestedLibrary")
                
                let query = PFUser.query()
                query?.findObjectsInBackground { (objects, error) in
                    print("Starting the process to remove the book from the second user's received requests librbary")
                    if let users = objects {
                        for object in users {
                            if let user = object as? PFUser {
                                if (user.username?.contains(self.requestedBookInformation[9] as! String))!{
                                    let wait1 = DispatchTime.now() + 1.0
                                    DispatchQueue.main.asyncAfter(deadline: wait1) {
                                        // Logout the initial current user
                                        PFUser.logOut()
                                        print("The initial user (\(self.currentUsername!)) was logged out...")
                                        
                                        let wait = DispatchTime.now() + 0.5
                                        DispatchQueue.main.asyncAfter(deadline: wait) {
                                            // Login the user that the initial current user is requesting the book from
                                            PFUser.logInWithUsername(inBackground: user.username!, password: user.object(forKey: "recoveryPassword") as! String, block: { (user, error) in
                                                if error != nil {
                                                    
                                                } else {
                                                    print("Success! Second user (\(PFUser.current()!.username!)) is logged in.")
                                                    self.secondUser = PFUser.current()!.username!
                                                    
                                                    // Set the second user's received request librbary
                                                    var requestedUserReceivedReqeuests = PFUser.current()!.object(forKey: "receivedRequestsLibrary") as! Array<Array<AnyObject>>
                                                    
                                                    for i in 0..<requestedUserReceivedReqeuests.count{
                                                        // if the title of the book about to be deleted matches the title of the book in the user's array
                                                        if requestedUserReceivedReqeuests[i][0] as! String == self.matchingTitle {
                                                            // Remove the book from the second User's received requests library
                                                            print("MATCH FOUND! \(requestedUserReceivedReqeuests[i][0])")
                                                            requestedUserReceivedReqeuests.remove(at: i)
                                                        }
                                                    }
                                                    
                                                    // If the second user's received request library's count is now 0, set the didReceiveFirstRequest boolean back to false
                                                        if requestedUserReceivedReqeuests.count == 0 {
                                                            PFUser.current()!.setValue(false, forKey: "didReceiveFirstRequest")
                                                            print("\(self.secondUser)'s sent request library is now empty.")
                                                        }
                                                    
                                                    // Set the second user's received request library on the server
                                                    GUSUerLibrary(requestedUserReceivedReqeuests as [AnyObject], "receivedRequestsLibrary", "didReceiveFirstRequest")
                                                    
                                                    let wait = DispatchTime.now() + 2.5
                                                    DispatchQueue.main.asyncAfter(deadline: wait) {
                                                        PFUser.logOut()
                                                        print("The second user (\(self.secondUser)) is logged out..")
                                                        
                                                        let wait3 = DispatchTime.now() + 1.5
                                                        DispatchQueue.main.asyncAfter(deadline: wait3){
                                                            print("Attempting to log back in the original current user")
                                                            PFUser.logInWithUsername(inBackground: self.currentUsername!, password: self.currentUserPassword as! String, block: { (user, error) in
                                                                if error != nil {
                                                                    
                                                                } else {
                                                                    print("Success! The original user (\(PFUser.current()!.username!)) is logged back in.")
                                                                    
                                                                    print("The process is complete!")
                                                                    
                                                                    self.activityIndicator.stopAnimating()
                                                                    UIApplication.shared.endIgnoringInteractionEvents()
                                                                    
                                                                    let successAlert = UIAlertController(title: "Complete!", message: "The cancellation of your request is complete!", preferredStyle: UIAlertControllerStyle.alert)
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
        
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            var receivedRequestedLibrary = PFUser.current()!.object(forKey: "receivedRequestsLibrary") as! Array<Array<AnyObject>>
            let alert = UIAlertController(title: "Approve Request?", message: "Approve \(self.requestedBookInformation[12])'s request to borrow '\(self.requestedBookInformation[0])' until \(requestedBookInformation[11])?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                // Start the activity spinner
                self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                self.activityIndicator.center = self.view.center
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                self.view.addSubview(self.activityIndicator)
                self.activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                
                
                print("Current requested library is: \(self.currentRequestedLibrary)")
                print("Requested book infromation is: \(self.requestedBookInformation)")
                
                // Remove the book from the original user's received requested library
                for i in 0..<receivedRequestedLibrary.count{
                    print("Looping through currentRequestedLibrary")
                    // if the title of the book about to be deleted matches the title of the book in the user's array
                    if receivedRequestedLibrary[i][0] as! String == self.requestedBookInformation[0] as! String {
                        // Remove the book from the current User's sent requests library
                        print("MATCH FOUND! \(receivedRequestedLibrary[i][0])")
                        self.matchingTitle = receivedRequestedLibrary[i][0] as! String
                        receivedRequestedLibrary.remove(at: i)
                    }
                }
                print("Finished removing the book from the original user's requested library")
                
                // if the current user's requested library count is now 0, set the boolean back to false on the server
                if receivedRequestedLibrary.count == 0 {
                    updateBoolStats(false, "didReceiveFirstRequest")
                    print("\(self.currentUsername!)'s received request library is now empty.")
                }
                
                // update the deletion on the server
                updateArray(receivedRequestedLibrary, "receivedRequestsLibrary")
                
                // Set the status of the book to 'borrowed'
                self.requestedBookInformation[6] = "Lent" as AnyObject
                
                // Update the newly borrowed book on the server
                GUSUerLibrary(self.requestedBookInformation, "lentBooks", "lentFirstBook")
                
                let query = PFUser.query()
                query?.findObjectsInBackground { (objects, error) in
                    print("Starting the process to remove the book from the second user's received requests librbary")
                    if let users = objects {
                        for object in users {
                            if let user = object as? PFUser {
                                if (user.username?.contains(self.requestedBookInformation[12] as! String))!{
                                    let wait1 = DispatchTime.now() + 1.0
                                    DispatchQueue.main.asyncAfter(deadline: wait1) {
                                        // Logout the initial current user
                                        PFUser.logOut()
                                        print("The initial user (\(self.currentUsername!)) was logged out...")
                                        
                                        let wait = DispatchTime.now() + 0.5
                                        DispatchQueue.main.asyncAfter(deadline: wait) {
                                            // Login the user that the initial current user is requesting the book from
                                            PFUser.logInWithUsername(inBackground: user.username!, password: user.object(forKey: "recoveryPassword") as! String, block: { (user, error) in
                                                if error != nil {
                                                    
                                                } else {
                                                    print("Success! Second user (\(PFUser.current()!.username!)) is logged in.")
                                                    self.secondUser = PFUser.current()!.username!
                                                    
                                                    // Set the second user's received request librbary
                                                    var requestedUserSentReqeuests = PFUser.current()!.object(forKey: "requestedLibrary") as! Array<Array<AnyObject>>
                                                    
                                                    for i in 0..<requestedUserSentReqeuests.count{
                                                        // if the title of the book about to be deleted matches the title of the book in the user's array
                                                        if requestedUserSentReqeuests[i][0] as! String == self.matchingTitle {
                                                            // Remove the book from the second User's received requests library
                                                            print("MATCH FOUND! \(requestedUserSentReqeuests[i][0])")
                                                            requestedUserSentReqeuests.remove(at: i)
                                                        }
                                                    }
                                                    
                                                    print("RequestedUsersSentRequests count is \(requestedUserSentReqeuests.count)")
                                                    
                                                    // Set the second user's sent request library on the server
                                                    GUSUerLibrary(requestedUserSentReqeuests as [AnyObject], "requestedLibrary", "didRequestFirstBook")
                                                    
                                                    // If the second user's received request library's count is now 0, set the didReceiveFirstRequest boolean back to false
                                                    if requestedUserSentReqeuests.count == 0 {
                                                        PFUser.current()!.setValue(false, forKey: "didRequestFirstBook")
                                                        print("\(self.secondUser)'s sent request library is now empty.")
                                                    }
                                                    
                                                    // Set the status of the book to 'lent'
                                                    self.requestedBookInformation[6] = "Borrowed" as AnyObject
                                                    
                                                    // Update the newly borrowed book on the server
                                                    GUSUerLibrary(self.requestedBookInformation, "borrowedBooks", "borrowedFirstBook")
                                                    
                                                    let wait = DispatchTime.now() + 2.5
                                                    DispatchQueue.main.asyncAfter(deadline: wait) {
                                                        PFUser.logOut()
                                                        print("The second user (\(self.secondUser)) is logged out..")
                                                        
                                                        let wait3 = DispatchTime.now() + 1.5
                                                        DispatchQueue.main.asyncAfter(deadline: wait3){
                                                            print("Attempting to log back in the original current user")
                                                            PFUser.logInWithUsername(inBackground: self.currentUsername!, password: self.currentUserPassword as! String, block: { (user, error) in
                                                                if error != nil {
                                                                    
                                                                } else {
                                                                    print("Success! The original user (\(PFUser.current()!.username!)) is logged back in.")
                                                                    
                                                                    print("The process is complete!")
                                                                    
                                                                    self.activityIndicator.stopAnimating()
                                                                    UIApplication.shared.endIgnoringInteractionEvents()
                                                                    
                                                                    let successAlert = UIAlertController(title: "Complete!", message: "The approval of your request has completed!", preferredStyle: UIAlertControllerStyle.alert)
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
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func denyRequestAction(_ sender: UIButton) {
        
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

