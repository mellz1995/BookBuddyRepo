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

class SearchedUserInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userLibrary = Array<Array<AnyObject>>()
    public var userInforomation = Array<AnyObject>()
    var requestedBook = Array<AnyObject>()

    override func viewDidLoad() {
        super.viewDidLoad()
        if comingFromSearch == true {
            userInforomation = userInformationArray[0]
        }

        print("Userinformation array is \(userInforomation)")
        
        userLibrary = searcedUserLibraryArray
        
        print("User library from searchedInformationViewController is \(userLibrary)")
        
        
        
        setEverythingUp()
    }
    
    @IBOutlet weak var tableViewSearched: UITableView!
    
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
    
    @IBOutlet weak var settingsOutlet: UIButton!
    @IBAction func settingsAction(_ sender: UIButton) {
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRows = 0
        
        // Gets the number of rows in the section
        if userInforomation[3] as! Bool == false {
            numOfRows = 1
        } else {
            numOfRows = userLibrary.count
        }
        
        return numOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTable", for: indexPath) as? ProfileLibraryTableViewCell else {
            fatalError("The dequed cell is not an instance of BooksTableViewCell")
        }
        
        if userInforomation[3] as! Bool == false {
            cell.titleLabel.text = "No books"
            cell.isUserInteractionEnabled = false
            cell.statusImageView.image = #imageLiteral(resourceName: "SadBook")
            cell.bookImage.image = #imageLiteral(resourceName: "QuestionMarkBook")
        } else {
            cell.isUserInteractionEnabled = true
            if userLibrary[indexPath.row].isEmpty == false {
                cell.titleLabel.text = userLibrary[indexPath.row][0] as? String
                if userLibrary[indexPath.row][1] as! String == "Not specified"{
                    cell.authorLabel.text = "No Author Listed"
                } else {
                    cell.authorLabel.text = userLibrary[indexPath.row][1] as? String
                }
                if userLibrary[indexPath.row][2] as! String == "Not specified"{
                    cell.isbn10Label.text = "No ISBN for this book"
                } else {
                    cell.isbn10Label.text = userLibrary[indexPath.row][2] as? String
                }
                
                if userLibrary[indexPath.row][6] as! String == "Owned"{
                    cell.statusImageView.image = #imageLiteral(resourceName: "OwnedImage")
                }
                
                if userLibrary[indexPath.row][6] as! String == "Lent"  {
                    cell.statusImageView.image = #imageLiteral(resourceName: "LentBlueImage")
                }
                
                if userLibrary[indexPath.row][6] as! String == "Borrowed" {
                    cell.statusImageView.image = #imageLiteral(resourceName: "BorrowedBlueImage")
                }
                
                // Set the image of the book
                if let bookPicture = userLibrary[indexPath.row][7] as? PFFile {
                    bookPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                        let image = UIImage(data: imageData!)
                        if image != nil {
                            cell.bookImage.image = image
                        }
                    })
                }
            }
        }
        
        return cell
        
    }
    
    // Override to support conditional editing of the table view.
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var isEditable = false
        // Return false if you do not want the specified item to be editable.
        // Check to see if the user library is empty or not. If it is. Disable the edit button
        if userInforomation[3] as! Bool == false{
            isEditable = false
        } else {
            isEditable = true
        }
        return isEditable
    }
    
    // Override to support editing the table view.
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Request") { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            
            let alert = UIAlertController(title: "Request Book?", message: "Request to borrow '\(self.userLibrary[indexPath.row][0])'?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                for i in 0..<self.userLibrary[indexPath.row].count {
                    self.requestedBook.append(self.userLibrary[indexPath.row][i])
                }
                print("The requested book is: \(self.requestedBook)")
                print("Picture should be \(self.userLibrary[indexPath.row][7])")
                
                // Add the requested book to the user's requested library
                GUSUerLibrary(self.requestedBook, "requestedLibrary", "didRequestFirstBook")
                
                // Clear the requestedBook array
                self.requestedBook.removeAll()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        editAction.backgroundColor =  UIColor.green
        return [editAction]
        
        
        
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
