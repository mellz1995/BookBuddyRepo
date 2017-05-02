//
//  DeletedBooksTableViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/26/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse
import os.log
import GoogleMobileAds

class DeletedBooksTableViewController: UITableViewController {

    // Variable for the current deleted library
    var currentLibrary = Array<Array<AnyObject>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.alpha = 1
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        // You have to add your app id when you register your admob account!! This is just a test ad that won't make you any money, fool
        
        //The other place you have this is in the app delegate
        bannerView.adUnitID = "ca-app-pub-9692686923892592/9608344067"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        // Set the title
        navigationItem.title = "Deleted Books"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        // Load the current deleted user library
        currentLibrary = PFUser.current()?.object(forKey: "deletedLibrary") as! Array<Array<AnyObject>>
        
        // Check to see if the user's deleted library is empty or not. If it is. Disable the edit button
        if PFUser.current()!.object(forKey: "didDeleteFirstBook") as! Bool == false {
            editButtonItem.isEnabled = false
        } else {
            editButtonItem.isEnabled = true
        }
        
        deleteAllBooksOutlet.isEnabled = false
        editButtonItem.isEnabled = false
        restoreAllButtonOutlet.isEnabled = false
        
    }
    @IBOutlet weak var bannerView: GADBannerView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numOfRows = 0
        
        // Gets the number of rows in the section
        if PFUser.current()!.object(forKey: "didDeleteFirstBook") as! Bool == false {
            numOfRows = 1
        } else {
            numOfRows = currentLibrary.count
        }
        
        return numOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Downcasted to to BooksTableViewCell.swift to use the properties enlisted there
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeletedBooksCell", for: indexPath) as? DeletedBooksTableViewCell else {
            fatalError("The dequed cell is not an instance of BooksTableViewCell")
        }

        if PFUser.current()!.object(forKey: "didDeleteFirstBook") as! Bool == false {
            deleteAllBooksOutlet.isEnabled = false
            editButtonItem.isEnabled = false
            cell.bookTitleLabel.text = "No Books"
            cell.isUserInteractionEnabled = false
            cell.bookImage.image = #imageLiteral(resourceName: "QuestionMarkBook")
        } else {
            deleteAllBooksOutlet.isEnabled = true
            editButtonItem.isEnabled = true
            restoreAllButtonOutlet.isEnabled = true
            cell.isUserInteractionEnabled = true
            if currentLibrary[indexPath.row].isEmpty == false {
                cell.bookTitleLabel.text = currentLibrary[indexPath.row][0] as? String
                if currentLibrary[indexPath.row][1] as! String == "Not specified"{
                    cell.authorLabel.text = "No Author Listed"
                } else {
                    cell.authorLabel.text = currentLibrary[indexPath.row][1] as? String
                }
                if currentLibrary[indexPath.row][2] as! String == "Not specified"{
                    cell.isbnLabel.text = "No ISBN for this book"
                } else {
                    cell.isbnLabel.text = currentLibrary[indexPath.row][2] as? String
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
        

        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var isEditable = false
        // Check to see if the user library is empty or not. If it is. Disable the edit button
        if PFUser.current()!.object(forKey: "didDeleteFirstBook") as! Bool == false {
            isEditable = false
        } else {
            isEditable = true
        }
        
        return isEditable
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Permanently delete '\(currentLibrary[indexPath.row][0])'?", message: "Warning. You can not undo this action.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                self.currentLibrary.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                if self.currentLibrary.count == 0 {
                    updateBoolStats(false, "didDeleteFirstBook")
                }
                updateArray(self.currentLibrary, "deletedLibrary")
                
                self.tableView.reloadData()
                self.viewDidLoad()
            }))
            
            alert.addAction(UIAlertAction(title: "Don't delete", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    
    
    @IBOutlet weak var deleteAllBooksOutlet: UIBarButtonItem!
    @IBAction func deleteAllBooksButtonAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete all books?", message: "This will delete all books permanently. Delete?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.currentLibrary.removeAll()
            updateBoolStats(false, "didDeleteFirstBook")
            self.tableView.reloadData()
            self.viewDidLoad()
            self.editButtonItem.isEnabled = false
            self.deleteAllBooksOutlet.isEnabled = false
        }))
        
        alert.addAction(UIAlertAction(title: "No, don't delete", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var restoreAllButtonOutlet: UIBarButtonItem!
    @IBAction func restoreAllButtonAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Restore all books?", message: "This will restore all books back to your library.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            // Loops through the currentLibrary (user's deleted library) and appends them to the the library on the server
            for i in 0..<self.currentLibrary.count{
                GUSUerLibrary(self.currentLibrary[i], "library", "didSaveFirstBook")
            }
            
            self.currentLibrary.removeAll()
            updateBoolStats(false, "didDeleteFirstBook")
            self.tableView.reloadData()
            self.viewDidLoad()
            self.editButtonItem.isEnabled = false
            self.deleteAllBooksOutlet.isEnabled = false
            self.restoreAllButtonOutlet.isEnabled = false
        }))
        
        alert.addAction(UIAlertAction(title: "No, don't restore.", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func reloadData(){
        self.tableView.reloadData()
        self.viewDidLoad()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? ""){
        case "DeletedBookInformation":
            os_log("Showing book detail", log: OSLog.default, type: .debug)
            
            guard let deletedBookInformationViewController = segue.destination as? DeletedBookInformationViewController
                else {
                    fatalError("Unexpected destiniation: \(segue.destination)")
            }
            
            guard let selectedBookCell = sender as? DeletedBooksTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedBook = currentLibrary[indexPath.row]
            deletedBookInformationViewController.bookInformationArray = selectedBook
            
            
            
        case "DeletedMainMenu":
            os_log("Going to the main menu", log: OSLog.default, type: .debug)
            
        default:
            fatalError("Unexpected Segueue Identifier: \(String(describing: segue.identifier))")
            
        }
    }
    

}
