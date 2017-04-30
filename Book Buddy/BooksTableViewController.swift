//
//  BooksTableViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/22/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse
import os.log
import GoogleMobileAds

var libraryMode = "owned"

class BooksTableViewController: UITableViewController {
    
    var currentLibrary = Array<Array<AnyObject>>()
    var editButtonIsActive = false
    
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        if segmentedControlOutlet.selectedSegmentIndex == 0 {
            currentLibrary.removeAll()
            libraryMode = "owned"
            print("Mode is \(libraryMode)")
            currentLibrary = PFUser.current()?.object(forKey: "library") as! Array<Array<AnyObject>>
            self.tableView.reloadData()
        } else if segmentedControlOutlet.selectedSegmentIndex == 1 {
            currentLibrary.removeAll()
            libraryMode = "borrowed"
            print("Mode is \(libraryMode)")
            currentLibrary = PFUser.current()!.object(forKey: "borrowedBooks") as! Array<Array<AnyObject>>
            self.tableView.reloadData()
        } else if segmentedControlOutlet.selectedSegmentIndex == 2 {
            currentLibrary.removeAll()
            currentLibrary = PFUser.current()!.object(forKey: "lentBooks") as! Array<Array<AnyObject>>
            libraryMode = "lent"
            print("Mode is \(libraryMode)")
            self.tableView.reloadData()
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        navigationItem.title = "Your Library"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        libraryMode = "owned"
        
        // Load currentLibrary
        currentLibrary = PFUser.current()?.object(forKey: "library") as! Array<Array<AnyObject>>
        
        // Check to see if the user library is empty or not. If it is. Disable the edit button
        if PFUser.current()!.object(forKey: "didSaveFirstBook") as! Bool == false {
            editButtonItem.isEnabled = false
        } else {
            editButtonItem.isEnabled = true
        }
        
        bannerView.alpha = 1
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        // You have to add your app id when you register your admob account!! This is just a test ad that won't make you any money, fool
        
        //The other place you have this is in the app delegate
        bannerView.adUnitID = "ca-app-pub-9692686923892592/9608344067"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidAppear(_ animated: Bool) {
        print("View did appear!")
        DispatchQueue.main.async {
            super.viewWillAppear(true)
            // Check to see if the user library is empty or not. If it is. Disable the edit button
            if self.currentLibrary.count == 0 {
                self.editButtonItem.isEnabled = false
            } else {
                self.editButtonItem.isEnabled = true
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


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numOfRows = 0
        
        // Gets the number of rows in the section
        if libraryMode == "owned"{
            if PFUser.current()!.object(forKey: "didSaveFirstBook") as! Bool == false {
                numOfRows = 1
            } else {
                numOfRows = currentLibrary.count
            }
        } else if libraryMode == "borrowed" {
            if PFUser.current()!.object(forKey: "borrowedFirstBook") as! Bool == false {
                numOfRows = 1
            } else {
                numOfRows = currentLibrary.count
            }
            
        } else if libraryMode == "lent" {
            if PFUser.current()!.object(forKey: "lentFirstBook") as! Bool == false {
                numOfRows = 1
            } else {
                numOfRows = currentLibrary.count
            }
            
        }
     
        return numOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Downcasted to to BooksTableViewCell.swift to use the properties enlisted there
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? BooksTableViewCell else {
            fatalError("The dequed cell is not an instance of BooksTableViewCell")
        }
        
        if libraryMode == "owned" {
            if PFUser.current()!.object(forKey: "didSaveFirstBook") as! Bool == false {
                cell.titleLabel.text = "No owned books"
                cell.isUserInteractionEnabled = false
                cell.statusImageView.image = #imageLiteral(resourceName: "SadBook")
                cell.bookImage.image = #imageLiteral(resourceName: "QuestionMarkBook")
                cell.authorLabel.text = ""
                cell.isbn10Label.text = ""
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
        } else if libraryMode == "borrowed" {
            if PFUser.current()!.object(forKey: "borrowedFirstBook") as! Bool == false {
                cell.titleLabel.text = "No borrowed books"
                cell.isUserInteractionEnabled = false
                cell.statusImageView.image = #imageLiteral(resourceName: "SadBook")
                cell.bookImage.image = #imageLiteral(resourceName: "QuestionMarkBook")
                cell.authorLabel.text = ""
                cell.isbn10Label.text = ""
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
        } else if libraryMode == "lent" {
            if PFUser.current()!.object(forKey: "lentFirstBook") as! Bool == false {
                cell.titleLabel.text = "No lent books"
                cell.isUserInteractionEnabled = false
                cell.statusImageView.image = #imageLiteral(resourceName: "SadBook")
                cell.bookImage.image = #imageLiteral(resourceName: "QuestionMarkBook")
                cell.authorLabel.text = ""
                cell.isbn10Label.text = ""
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
        }
        
    return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // If the user deletes a book
        if editingStyle == .delete {
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

            if currentLibrary.count == 0 {
                updateBoolStats(false, "didSaveFirstBook")
            }
            updateArray(currentLibrary, "library")
            
            self.tableView.reloadData()
            self.viewDidLoad()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? ""){
        case "ShowDetail":
            os_log("Showing book detail", log: OSLog.default, type: .debug)
            
            guard let bookInformationViewController = segue.destination as? BookInformationViewController
                else {
                    fatalError("Unexpected destiniation: \(segue.destination)")
            }
            
            guard let selectedBookCell = sender as? BooksTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
          
            let selectedBook = currentLibrary[indexPath.row]
            bookInformationViewController.bookInformationArray = selectedBook
            
            
        case "AddBook":
            os_log("Adding Book", log: OSLog.default, type: .debug)
            
        case "MainMenu":
            os_log("Going to the main menu", log: OSLog.default, type: .debug)
            
        default:
            fatalError("Unexpected Segueue Identifier: \(String(describing: segue.identifier))")
            
        }
    }
 
    

}
