//
//  TestManualEntryViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/20/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
//import Parse
import os.log

class TestManualEntryViewController: UIViewController {
    
    var userLibrary = [[String]]()
    var newBook = [String]()
    var saveButtonTimer = Timer()
    var activityIndicator = UIActivityIndicatorView()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start the timer to see if to enable save button or not
        startSaveButtonTimer()
        // Disable the save button until user enters a title
        saveButtonOutlet.isEnabled = false
        

        // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TestManualEntryViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // If the user has just returned from the scanned screen, search the scanned barcode
        if scanned {
            
            dismissKeyboard()
            
            // Start the activity spinner
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            searchScannedResult(scannedBarcode)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var isbn10TextField: UITextField!
    @IBOutlet weak var isbn13TextField: UITextField!
    @IBOutlet weak var publisherTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    
//    @IBAction func deleteAllButtonAction(_ sender: UIButton) {
//        let alert = UIAlertController(title: "Delete?", message: "This will delete your ENTIRE library. You can't undo this. Proceed?", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Yes, delete.", style: .default, handler: { (action) in
//            // Delete the entire library
//            self.userLibrary.removeAll()
//            print()
//            print("Deleted the userLibrary")
//            // Set the userLibrary on the parse server to an empty 2D array
//            PFUser.current()!.setValue([[]], forKey: "library")
//            
//            // Set the didSetFirstBook boolean back to false
//            updateBoolStats(false, "didSaveFirstBook")
//        }))
//        
//        alert.addAction(UIAlertAction(title: "No, don't delete.", style: .default, handler: { (action) in
//            
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }
    
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
        print()
        print("Current library is \(userLibrary)")
        
        // Append the newBook array with the contents of the text fields
        // Check to see if the text fields are empty first! The user is not required to enter all information on a book if they wish not to do so
        
        if (titleTextField.text?.isEmpty)!{
            newBook.append("Not specified")
        } else {
            newBook.append(titleTextField.text!)
        }
        
        if (authorTextField.text?.isEmpty)!{
            newBook.append("Not specified")
        } else {
            newBook.append(authorTextField.text!)
        }
        
        if (isbn10TextField.text?.isEmpty)!{
            newBook.append("Not specified")
        } else {
            newBook.append(isbn10TextField.text!)
        }
        
        if (isbn13TextField.text?.isEmpty)!{
            newBook.append("Not specified")
        } else {
            newBook.append(isbn13TextField.text!)
        }
        
        if (publisherTextField.text?.isEmpty)!{
            newBook.append("Not specified")
        } else {
            newBook.append(publisherTextField.text!)
        }
        
        if (languageTextField.text?.isEmpty)! {
            newBook.append("Not specified")
        } else {
            newBook.append(languageTextField.text!)
        }
        
        // Add a status to the book (Owned, Lent, Borrowed)
        newBook.append("Owned")
        
        // Add the current user as owner of the book
        //newBook.append((PFUser.current()?.username!)!)
        
        // Add the new book to the server
        GUSUerLibrary(self.newBook)
    }
    
    func startSaveButtonTimer(){
        saveButtonTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.checkSaveButton), userInfo: nil, repeats: true)
    }
    
    func checkSaveButton(){
        if (titleTextField.text?.isEmpty)!{
            saveButtonOutlet.isEnabled = false
        } else {
            saveButtonOutlet.isEnabled = true
        }
    }
    
    // This function is called when the user scans a book's barcode
    func searchScannedResult(_ searchQueary: String){
        // Remove spaces
        let noSpaces = searchQueary.replacingOccurrences(of: " ", with: "_")
        
        // Remove commas
        let noCommas = noSpaces.replacingOccurrences(of: ",", with: "")
        
        // Remove periods
        let noPeriods = noCommas.replacingOccurrences(of: ".", with: "")
        
        // Replace slashes
        let noSlashes = noPeriods.replacingOccurrences(of: "/", with: "")
        
        // Set the final search query
        let finalSearchQuery = noSlashes
        
        // Set the url with my set api key and the final search querey
        let url = URL(string: "http://isbndb.com/api/v2/json/\(mykey)/books?q=\(finalSearchQuery)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print(error!)
            } else {
                if let urlContent = data {
                    
                    do {
                        let jsonResult = try  JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        //print(jsonResult)
                        
                        // Get the title
                        if let datas = jsonResult["data"] as? [[String: Any]] {
                            
                            for data in datas {
                                DispatchQueue.main.async {
                                    // Get the title
                                    if let title = data["title"] as? String{
                                        if title.isEmpty {
                                            print("The title is not specified")
                                            self.newBook.append("Not specified")
                                            self.titleTextField.text = "Not specified"
                                        } else {
                                            print("Title is \(title)")
                                            self.newBook.append(title)
                                            self.titleTextField.text = title
                                        }
                                    } else {
                                        print("Error with getting title.")
                                        self.newBook.append("Not specified")
                                    }
                                    
                                    // Get the author
                                    if let authorData = data["author_data"] as? [[String: Any]]{
                                        for authorDatas in authorData {
                                            if let authorName = authorDatas["name"] as? String{
                                                if authorName.isEmpty{
                                                    print("The authorName is not specified")
                                                    self.newBook.append("Not specified")
                                                    self.authorTextField.text = "Not specified"
                                                } else {
                                                    print("Author is \(authorName)")
                                                    self.newBook.append(authorName)
                                                    self.authorTextField.text = authorName
                                                }
                                            } else {
                                                print("Error with getting Author.")
                                                self.newBook.append("Not specified")
                                            }
                                        }
                                    }
                                    
                                    // Get the ISBN10
                                    if let isbn10 = data["isbn10"] as? String{
                                        if isbn10.isEmpty {
                                            print("ISBN10 is not specified")
                                            self.newBook.append("Not specified")
                                            self.isbn10TextField.text = "Not specified"
                                        } else {
                                            print("ISBN10 is \(isbn10)")
                                            self.newBook.append(isbn10)
                                            self.isbn10TextField.text = isbn10
                                        }
                                    } else {
                                        print("Error with getting ISBN10.")
                                        self.newBook.append("Not specified")
                                    }
                                    
                                    // Get the ISBN13
                                    if let isbn13 = data["isbn13"] as? String{
                                        if isbn13.isEmpty {
                                            print("ISBN13 is not specified")
                                            self.newBook.append("Not specified")
                                            self.isbn13TextField.text = "Not specified"
                                        } else {
                                            print("ISBN13 is \(isbn13)")
                                            self.newBook.append(isbn13)
                                            self.isbn13TextField.text = isbn13
                                        }
                                    } else {
                                        print("Error with getting ISBN13.")
                                        self.newBook.append("Not specified")
                                    }
                                    
                                    // Get the publisher
                                    if let publisher = data["publisher_name"] as? String{
                                        if publisher.isEmpty {
                                            print("The publisher is not specified")
                                            self.newBook.append("Not specified")
                                            self.publisherTextField.text = "Not specified"
                                        } else {
                                            print("Publisher is \(publisher)")
                                            self.newBook.append(publisher)
                                            self.publisherTextField.text = publisher
                                        }
                                    } else {
                                        print("Error with getting publisher.")
                                        self.newBook.append("Not specified")
                                    }
                                    
                                    // Get the langauge
                                    if let langauge = data["language"] as? String{
                                        if langauge.isEmpty{
                                            print("The language is not specified")
                                            self.newBook.append("Not specified")
                                            self.languageTextField.text = "Not specified"
                                        } else {
                                            print("Language is \(langauge)")
                                            self.newBook.append(langauge)
                                            self.languageTextField.text = langauge
                                        }
                                    } else {
                                        print("Error with getting langauge.")
                                        self.newBook.append("Not specified")
                                    }
                                    
                                    // Print that the book is owned since user is adding to the library
                                    self.newBook.append("Owned")
                                    
                                    
                                    print()
                                    print("End of file! Newly added book is: ")
                                    
                                    //Print out the newly added book's information
                                    for i in 0..<self.newBook.count{
                                        if i == 0 {
                                            print("Title: \(self.newBook[i])")
                                        }
                                        
                                        if i == 1 {
                                            print("Author: \(self.newBook[i])")
                                        }
                                        
                                        if i == 2 {
                                            print("ISBN10: \(self.newBook[i])")
                                        }
                                        
                                        if i == 3 {
                                            print("ISBN13: \(self.newBook[i])")
                                        }
                                        
                                        if i == 4 {
                                            print("Publisher: \(self.newBook[i])")
                                        }
                                        
                                        if i == 5 {
                                            print("Language: \(self.newBook[i])")
                                        }
                                        
                                        if i == 6 {
                                            print("Status: \(self.newBook[i])")
                                        }
                                    }
                                    
                                    // Add the new book to the server
                                    //GUSUerLibrary(self.newBook)
                                    
                                    // Remove all contents of the newBook array
                                    self.newBook.removeAll()
                                    print("NewBookArrayCleared")
                                    
                                    scanned = false
                                    print("Scanned is now false")
                                }
                            }
                        }
                    } catch {
                        DispatchQueue.main.async(execute: {
                            print("No resutls found...")
                            
                            // In the case of a book not being found by a scanned barcode, the newBook array will get appended with a lot of "Not specified's". To prevent this being a problem, clear the newBook array
                            self.newBook.removeAll()
                        })
                    }
                }
            }
        }
        task.resume()
        stopAnimator()
    }
    
    func stopAnimator(){
        UIApplication.shared.endIgnoringInteractionEvents()
        self.activityIndicator.stopAnimating()
    }

}
