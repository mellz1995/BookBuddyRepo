//
//  ProfileViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 4/5/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentLibrary = Array<Array<AnyObject>>()
    var mode = "owned"
    var requestedLibrary = PFUser.current()!.object(forKey: "requestedLibrary") as! Array<Array<AnyObject>>
    
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIButton!
    @IBAction func profilePictureAction(_ sender: UIButton) {
        
    }
    
    @IBOutlet weak var ownedOutlet: UIButton!
    @IBOutlet weak var borrowedOutlet: UIButton!
    @IBOutlet weak var lentOutlet: UIButton!
    @IBOutlet weak var deletedOutlet: UIButton!
    @IBOutlet weak var tableViewMel: UITableView!
    @IBOutlet weak var linksAmountLabel: UILabel!
    @IBOutlet weak var requestAmountLabel: UILabel!
    
    @IBAction func ownedAction(_ sender: UIButton) {
        mode = "owned"
        ownedOutlet.alpha = 1
        borrowedOutlet.alpha = 0.5
        lentOutlet.alpha = 0.5
        deletedOutlet.alpha = 0.5
        
        currentLibrary.removeAll()
        
        currentLibrary = PFUser.current()?.object(forKey: "library") as! Array<Array<AnyObject>>
        
        //viewDidLoad()
        tableViewMel.reloadData()
    }
    
    @IBAction func borrowedAction(_ sender: UIButton) {
        mode = "borrowed"
        ownedOutlet.alpha = 0.5
        borrowedOutlet.alpha = 1.0
        lentOutlet.alpha = 0.5
        deletedOutlet.alpha = 0.5
        
        currentLibrary.removeAll()
        
        //viewDidLoad()
        //tableViewMel.reloadData()
    }
    
    @IBAction func lentAction(_ sender: UIButton) {
        mode = "lent"
        ownedOutlet.alpha = 0.5
        borrowedOutlet.alpha = 0.5
        lentOutlet.alpha = 1.0
        deletedOutlet.alpha = 0.5
        
        currentLibrary.removeAll()
        
        //viewDidLoad()
        //tableViewMel.reloadData()
    }
    
    @IBAction func deletedAction(_ sender: UIButton) {
        mode = "deleted"
        ownedOutlet.alpha = 0.5
        borrowedOutlet.alpha = 0.5
        lentOutlet.alpha = 0.5
        deletedOutlet.alpha = 1.0
        
        currentLibrary.removeAll()
        
        currentLibrary = PFUser.current()?.object(forKey: "deletedLibrary") as! Array<Array<AnyObject>>
        
        //viewDidLoad()
        tableViewMel.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = "\(PFUser.current()!.username!)"
        
        mode = "owned"
        
        refresh()
        
        
        
        // Load the current library
        currentLibrary = PFUser.current()?.object(forKey: "library") as! Array<Array<AnyObject>>
        
        ownedOutlet.alpha = 1
        borrowedOutlet.alpha = 0.5
        lentOutlet.alpha = 0.5
        deletedOutlet.alpha = 0.5
        
        if PFUser.current()!.object(forKey: "didSetProfilePic") as! Bool == false{
           // profilePictureOutlet.setImage(#imageLiteral(resourceName: "InitialSadBook"), for: [])
            profilePic.image = #imageLiteral(resourceName: "InitialSadBook")
        } else {
            if let userPicture = PFUser.current()!.object(forKey: "profilePic")! as? PFFile {
                userPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                    let image = UIImage(data: imageData!)
                    if image != nil {
                       // self.profilePictureOutlet.setImage(image, for: [])
                        self.profilePic.image = image
                    }
                })
            }
        }
    }
    
    func refresh(){
        var linksAmount = 0
        
        if PFUser.current()!.object(forKey: "didAddFirstFrend") as! Bool == false {
            linksAmount = 0
        } else {
            let linksList = PFUser.current()!.object(forKey: "friends") as! Array<Array<Any>>
            linksAmount = linksList.count
        }
        linksAmountLabel.text = "\(linksAmount)"
        requestAmountLabel.text = "\(requestedLibrary.count)"
    }
    
    // Override function that rounds the profile picture
    override func viewDidLayoutSubviews() {
        profilePictureOutlet.layer.cornerRadius = profilePictureOutlet.frame.size.width/2
        profilePictureOutlet.clipsToBounds = true
        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
        profilePic.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View did appear!")
        DispatchQueue.main.async {
            super.viewWillAppear(true)
            // Check to see if the user library is empty or not. If it is. Disable the edit button
            if self.currentLibrary.count == 0 {
               // self.editButtonItem.isEnabled = false
            } else {
               // self.editButtonItem.isEnabled = true
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRows = 0
        
        // Gets the number of rows in the section
        
        if mode == "owned" {
        
            if PFUser.current()!.object(forKey: "didSaveFirstBook") as! Bool == false {
                numOfRows = 1
            } else {
                numOfRows = currentLibrary.count
            }
            
        } else if mode == "deleted" {
            if PFUser.current()!.object(forKey: "didDeleteFirstBook") as! Bool == false {
                numOfRows = 1
            } else {
                numOfRows = currentLibrary.count
            }
        }
        
        return numOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLibraryID", for: indexPath) as? ProfileLibraryTableViewCell else {
            fatalError("The dequed cell is not an instance of BooksTableViewCell")
        }
        
        cell.multipleSelectionBackgroundView?.alpha = 0.3
        
        if mode == "owned" {
            if PFUser.current()!.object(forKey: "didSaveFirstBook") as! Bool == false {
                cell.titleLabel.text = "No books"
                cell.isUserInteractionEnabled = false
                cell.statusImageView.image = #imageLiteral(resourceName: "SadBook")
                cell.bookImage.image = #imageLiteral(resourceName: "QuestionMarkBook")
            } else {
                cell.isUserInteractionEnabled = true
                if currentLibrary[indexPath.row].isEmpty == false {
                    cell.titleLabel.text = currentLibrary[indexPath.row][0] as? String
                    if currentLibrary[indexPath.row][1] as! String == "Not specified"{
                        cell.authorLabel.text = "No Author Listed"
                    } else {
                        cell.authorLabel.text = currentLibrary[indexPath.row][1] as? String
                    }
                    if currentLibrary[indexPath.row][2] as! String == "Not specified"{
                        cell.isbn10Label.text = "No ISBN for this book"
                    } else {
                        cell.isbn10Label.text = currentLibrary[indexPath.row][2] as? String
                    }
                
                    if currentLibrary[indexPath.row][6] as! String == "Owned"{
                        cell.statusImageView.image = #imageLiteral(resourceName: "OwnedImage")
                    }
                
                    if currentLibrary[indexPath.row][6] as! String == "Lent"  {
                        cell.statusImageView.image = #imageLiteral(resourceName: "LentBlueImage")
                    }
                
                    if currentLibrary[indexPath.row][6] as! String == "Borrowed" {
                        cell.statusImageView.image = #imageLiteral(resourceName: "BorrowedBlueImage")
                    }
                
                    // Set the image of the book
                    if let bookPicture = currentLibrary[indexPath.row][7] as? PFFile {
                        bookPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                            let image = UIImage(data: imageData!)
                            if image != nil {
                                cell.bookImage.image = image
                            }
                        })
                    }
                }
            }
            
        } else if mode == "deleted" {
            if PFUser.current()!.object(forKey: "didDeleteFirstBook") as! Bool == false {
                //deleteAllBooksOutlet.isEnabled = false
                editButtonItem.isEnabled = false
                cell.titleLabel.text = "No Books"
                cell.authorLabel.text = ""
                cell.isbn10Label.text = ""
                cell.isUserInteractionEnabled = false
                cell.bookImage.image = #imageLiteral(resourceName: "QuestionMarkBook")
                cell.statusImageView.image = #imageLiteral(resourceName: "SadBook")
            } else {
                //deleteAllBooksOutlet.isEnabled = true
                editButtonItem.isEnabled = true
                //restoreAllButtonOutlet.isEnabled = true
                cell.isUserInteractionEnabled = true
                if currentLibrary[indexPath.row].isEmpty == false {
                    cell.titleLabel.text = currentLibrary[indexPath.row][0] as? String
                    if currentLibrary[indexPath.row][1] as! String == "Not specified"{
                        cell.authorLabel.text = "No Author Listed"
                    } else {
                        cell.authorLabel.text = currentLibrary[indexPath.row][1] as? String
                    }
                    if currentLibrary[indexPath.row][2] as! String == "Not specified"{
                        cell.isbn10Label.text = "No ISBN for this book"
                    } else {
                        cell.isbn10Label.text = currentLibrary[indexPath.row][2] as? String
                    }
                    
                    // Set the image of the book
                    if let bookPicture = currentLibrary[indexPath.row][7] as? PFFile {
                        bookPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                            let image = UIImage(data: imageData!)
                            if image != nil {
                                cell.bookImage.image = image
                            }
                        })
                    }
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
        if PFUser.current()!.object(forKey: "didSaveFirstBook") as! Bool == false {
            isEditable = false
        } else {
            isEditable = true
        }
        return isEditable
    }
    
    // Override to support editing the table view.
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // If the user deletes a book
        if editingStyle == .delete {
                if mode == "owned"{
                let alert = UIAlertController(title: "Delete Book?", message: "Delete '\(currentLibrary[indexPath.row][0])' from your library?", preferredStyle:    UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    // Append the deleted book to the server
                    GUSUerLibrary(self.currentLibrary[indexPath.row], "deletedLibrary", "didDeleteFirstBook")
                
                    self.currentLibrary.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                
                    if self.currentLibrary.count == 0 {
                        updateBoolStats(false, "didSaveFirstBook")
                    }
                    updateArray(self.currentLibrary, "library")
                
                    self.viewDidLoad()
                }))
            
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    self.viewDidLoad()
                }))
            
            
                self.present(alert, animated: true, completion: nil)
            
                } else if mode == "deleted" {
                    let alert = UIAlertController(title: "Delete Book?", message: "Permanentley '\(currentLibrary[indexPath.row][0])' from your library?", preferredStyle:    UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        // Remove this book from the deleted library
                        for i in 0..<self.currentLibrary.count{
                            if self.currentLibrary[i][10] as! Int == bookID {
                                self.currentLibrary.remove(at: i)
                                if self.currentLibrary.count == 0 {
                                    updateBoolStats(false, "didDeleteFirstBook")
                                }
                                updateArray(self.currentLibrary, "deletedLibrary")
                                self.currentLibrary.removeAll()
                            }
                        }
                        
                        self.viewDidLoad()
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        self.viewDidLoad()
                    }))
                    
                    
                    self.present(alert, animated: true, completion: nil)
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
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
