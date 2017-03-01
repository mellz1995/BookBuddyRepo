//
//  ViewSearchedUserLibraryTableViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 3/1/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse
import os.log

class ViewSearchedUserLibraryTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(currentUser)'s library"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searcedUserLibraryArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchedUserLibrary", for: indexPath) as? SearchedUserLibraryCell else {
            fatalError("The dequed cell is not an instance of BooksTableViewCell")
        }
        
        cell.bookTitle.text = searcedUserLibraryArray[indexPath.row][0] as? String
        if searcedUserLibraryArray[indexPath.row][1] as! String == "Not specified"{
            cell.authorLabel.text = "No Author Listed"
        } else {
            cell.authorLabel.text = searcedUserLibraryArray[indexPath.row][1] as? String
        }
        if searcedUserLibraryArray[indexPath.row][2] as! String == "Not specified"{
            cell.isbn10Label.text = "No ISBN for this book"
        } else {
            cell.isbn10Label.text = searcedUserLibraryArray[indexPath.row][2] as? String
        }
        
        // Set the image of the book
        if let bookPicture = searcedUserLibraryArray[indexPath.row][7] as? PFFile {
            bookPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                let image = UIImage(data: imageData!)
                if image != nil {
                    cell.bookImage.image = image
                }
            })
        }

        // Configure the cell...

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        case "SearchedUserLibrary":
            os_log("Showing book detail", log: OSLog.default, type: .debug)
            guard let userLibraryBookInformationViewController = segue.destination as? UserLibraryBookInformationViewController else {
                fatalError("Unexpected destiniation: \(segue.destination)")
            }
            
            guard let selectedBookCell = sender as? SearchedUserLibraryCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedBook = searcedUserLibraryArray[indexPath.row]
            userLibraryBookInformationViewController.bookInformationArray = selectedBook
        default:
            fatalError("Unexpected Segueue Identifier: \(segue.identifier)") 
        }
    }
    

}
