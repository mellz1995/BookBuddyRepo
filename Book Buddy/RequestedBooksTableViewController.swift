//
//  RequestedBooksTableViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 4/7/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse
import os.log

class RequestedBooksTableViewController: UITableViewController {
    
    var requestedLibrary = PFUser.current()!.object(forKey: "requestedLibrary") as! Array<Array<AnyObject>>
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the book's status to requested
        for i in 0..<requestedLibrary.count {
            requestedLibrary[i][6] = "Requested" as AnyObject
        }

        print("Requested Library is: \(requestedLibrary)")
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
        
        if PFUser.current()!.object(forKey: "didRequestFirstBook") as! Bool == false {
            numOfRows = 1
        } else {
            numOfRows = requestedLibrary.count
        }
        
        return numOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "requestedBooksCell", for: indexPath) as? ProfileLibraryTableViewCell else {
            fatalError("The dequed cell is not an instance of BooksTableViewCell")
        }

        if PFUser.current()!.object(forKey: "didRequestFirstBook") as! Bool == false {
            cell.titleLabel.text = "No books"
            cell.isUserInteractionEnabled = false
            cell.statusImageView.image = #imageLiteral(resourceName: "SadBook")
            cell.bookImage.image = #imageLiteral(resourceName: "QuestionMarkBook")
        } else {
            cell.isUserInteractionEnabled = true
            if requestedLibrary[indexPath.row].isEmpty == false {
                cell.titleLabel.text = requestedLibrary[indexPath.row][0] as? String
                if requestedLibrary[indexPath.row][1] as! String == "Not specified"{
                    cell.authorLabel.text = "No Author Listed"
                } else {
                    cell.authorLabel.text = requestedLibrary[indexPath.row][1] as? String
                }
                if requestedLibrary[indexPath.row][2] as! String == "Not specified"{
                    cell.isbn10Label.text = "No ISBN for this book"
                } else {
                    cell.isbn10Label.text = requestedLibrary[indexPath.row][2] as? String
                }
                
                if requestedLibrary[indexPath.row][6] as! String == "Owned"{
                    cell.statusImageView.image = #imageLiteral(resourceName: "OwnedImage")
                }
                
                if requestedLibrary[indexPath.row][6] as! String == "Lent"  {
                    cell.statusImageView.image = #imageLiteral(resourceName: "LentBlueImage")
                }
                
                if requestedLibrary[indexPath.row][6] as! String == "Borrowed" {
                    cell.statusImageView.image = #imageLiteral(resourceName: "BorrowedBlueImage")
                }
                
                if requestedLibrary[indexPath.row][6] as! String == "Requested" {
                    cell.statusImageView.image = #imageLiteral(resourceName: "RequestedImage")
                }
                
                // Set the image of the book
                if let bookPicture = requestedLibrary[indexPath.row][7] as? PFFile {
                    bookPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                        let image = UIImage(data: imageData!)
                        if image != nil {
                            cell.bookImage.image = image
                        }
                    })
                }
            }
        }
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Cancel") { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            
            let alert = UIAlertController(title: "Cancel Request?", message: "Cancel request to borrow '\(self.requestedLibrary[indexPath.row][0])'?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                // Remove book from requested library
                self.requestedLibrary.remove(at: indexPath.row)
                
                if self.requestedLibrary.count == 0 {
                    updateBoolStats(false, "didSaveFirstBook")
                }
                
                // update it on the server
                updateArray(self.requestedLibrary, "requestedLibrary")
                
                // reload the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        editAction.backgroundColor =  UIColor.red
        return [editAction]
        
        
        
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? ""){
        case "deletedInformation":
            os_log("Showing requestd book's information", log: OSLog.default, type: .debug)
            
            guard let requestedBookInformationViewController = segue.destination as? RequestedBookInformationViewController else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let selectedUserCell = sender as? ProfileLibraryTableViewCell else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedUserCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedRequestedBook = requestedLibrary[indexPath.row]
            requestedBookInformationViewController.requestedBookInformation = selectedRequestedBook
            
        case "BackToSearchSeg":
            os_log("Going back to search", log: OSLog.default, type: .debug)
            
        default:
            fatalError("Unexpected Segueue Identifier: \(String(describing: segue.identifier))")
            
        }
    }
    

}
