//
//  WishListTableViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 3/3/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse
import os.log

class WishListTableViewController: UITableViewController {
    
    var currentLibrary = Array<Array<AnyObject>>()
    var editButtonIsActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        comingFromWishList = true
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Load current wish list
        currentLibrary = PFUser.current()?.object(forKey: "wishList") as! Array<Array<AnyObject>>
        
        // Check to see if the user library is empty or not. If it is. Disable the edit and clear button
        if PFUser.current()!.object(forKey: "didSaveFirstWishListBook") as! Bool == false {
            //editButtonOutlet.isEnabled = false
            editButtonItem.isEnabled = false
            clearButtonOutlet.isEnabled = false
        } else {
            //editButtonOutlet.isEnabled = true
            editButtonItem.isEnabled = true
            clearButtonOutlet.isEnabled = true
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var clearButtonOutlet: UIBarButtonItem!
    @IBAction func clearButtonAction(_ sender: UIBarButtonItem) {
        print("Clear button tapped")
        let alert = UIAlertController(title: "Delete all books?", message: "This will delete all books permanently. Delete?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.currentLibrary.removeAll()
            updateBoolStats(false, "didSaveFirstWishListBook")
            self.tableView.reloadData()
            self.viewDidLoad()
            self.editButtonItem.isEnabled = false
            self.clearButtonOutlet.isEnabled = false
        }))
        
        alert.addAction(UIAlertAction(title: "No, don't delete", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var addButtonOutlet: UIBarButtonItem!
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        print("Add button tapped")
        comingFromWishList = true
    }
    
    @IBOutlet weak var editButtonOutlet: UIBarButtonItem!
    @IBAction func editButtonAction(_ sender: UIBarButtonItem) {
        print("Edit button tapped")
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numOfRows = 0
        
        // Gets the number of rows in the section
        if PFUser.current()!.object(forKey: "didSaveFirstWishListBook") as! Bool == false {
            numOfRows = 1
        } else {
            numOfRows = currentLibrary.count
        }
        
        return numOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WishListCell", for: indexPath) as? WishListCell else {
            fatalError("The dequed cell is not an instance of BooksTableViewCell")
        }

        if PFUser.current()!.object(forKey: "didSaveFirstWishListBook") as! Bool == false {
            cell.bookTitleLabel.text = "No Books"
            cell.isUserInteractionEnabled = false
            cell.bookImage.image = #imageLiteral(resourceName: "QuestionMarkBook")
        } else {
            cell.isUserInteractionEnabled = true
            cell.bookTitleLabel.text = currentLibrary[indexPath.row][0] as? String
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

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var isEditable = false
        // Return false if you do not want the specified item to be editable.
        // Check to see if the user library is empty or not. If it is. Disable the edit button
        if PFUser.current()!.object(forKey: "didSaveFirstWishListBook") as! Bool == false {
            isEditable = false
        } else {
            isEditable = true
        }
        return isEditable
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            currentLibrary.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if currentLibrary.count == 0 {
                updateBoolStats(false, "didSaveFirstWishListBook")
            }
            
            updateArray(currentLibrary, "wishList")
            
            self.tableView.reloadData()
            self.viewDidLoad()
            
        } else if editingStyle == .insert {
            
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? ""){
        case "WishListBookInformation":
            os_log("Showing book detail from wish list", log: OSLog.default, type: .debug)
            
            guard let bookInformationViewController = segue.destination as? BookInformationViewController
                else {
                    fatalError("Unexpected destiniation: \(segue.destination)")
            }
            
            guard let selectedBookCell = sender as? WishListCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedBook = currentLibrary[indexPath.row]
            bookInformationViewController.bookInformationArray = selectedBook
            
        case "AddBookToWishList":
            os_log("Adding Book to wish list", log: OSLog.default, type: .debug)
            
        case "MainMenuFromWishList":
            os_log("Going to the main menu", log: OSLog.default, type: .debug)
            
        default:
            fatalError("Unexpected Segueue Identifier: \(segue.identifier)")
        }
        
        
        
    }
    

}
