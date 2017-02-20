//
//  TestManualEntryViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/20/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class TestManualEntryViewController: UIViewController {
    
    var userLibrary = [[String]]()
    var newBook = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the current userLibrary
        userLibrary = PFUser.current()!.object(forKey: "library") as! [[String]]
        print()
        print("Current library is \(userLibrary)")
        

        // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TestManualEntryViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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
    
    @IBAction func addButonAction(_ sender: UIButton) {
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
        
        // Check to see if the currentUserLibrary is empty. If so, replace the index with that of the newBook array. If not, just append it
        if PFUser.current()!.object(forKey: "didSaveFirstBook") as! Bool == false {
            print()
            print("User library is empty")
            
            // Library is empty. Boolean will be changed when user adds a new book
            // Detlete the empty multi-dimensional array that's there
            userLibrary.removeAll()
            
            // Append the empty multi-dimensional array with the newBook single array
            userLibrary.append(newBook)
            
            // Save it on the Parse Server
            updateArray(userLibrary, "library")
            
            // Update the boolean variable to true for "didSaveFirstBook"
            updateBoolStats(true, "didSaveFirstBook")
            print()
            print("Updated library is \(userLibrary)")
            
            print()
            print("Library count is now \(userLibrary.count)")
            
            //Empty the newBook array so if the user wants to add another book without leaving the class, it doesn't append the previously added book along with the book they're adding next
            newBook.removeAll()
            print()
            print("newBook arry cleared")
            
        } else {
            // Library is not empty. Hooray!
            // Simply append then
            userLibrary.append(newBook)
            
            // Save it on the parse server
            updateArray(userLibrary, "library")
            print()
            print("Updated library is \(userLibrary)")
            print()
            print("Library count is now \(userLibrary.count)")
            
            //Empty the newBook array so if the user wants to add another book without leaving the class, it doesn't append the previously added book along with the book they're adding next
            newBook.removeAll()
            print()
            print("newBook arry cleared")
        }
    }
    
    @IBAction func deleteACertainBookAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Which book?", message: "Please enter the title of the book you want to delete in the text field and then hit delete.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: { (action) in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func deleteAllButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete?", message: "This will delete your ENTIRE library. You can't undo this. Proceed?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes, delete.", style: .default, handler: { (action) in
            // Delete the entire library
            self.userLibrary.removeAll()
            print()
            print("Deleted the userLibrary")
            // Set the userLibrary on the parse server to an empty 2D array
            PFUser.current()!.setValue([[]], forKey: "library")
            
            // Set the didSetFirstBook boolean back to false
            updateBoolStats(false, "didSaveFirstBook")
        }))
        
        alert.addAction(UIAlertAction(title: "No, don't delete.", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func finalDeleteButtonAction(_ sender: UIButton) {
            // Loops through all arrays in userLibrary
            for j in 0...userLibrary.count{
                for k in 0...userLibrary[j].count{
                    print(userLibrary[j][k])
                // If one of the titles in the 2D array matches the title, then delete it
                if userLibrary[j][k] == titleTextField.text {
                    userLibrary.remove(at: [j][k])
                    // Save it on the parse server
                    updateArray(userLibrary, "library")
                    print()
                    print("Updated library is \(userLibrary)")
                    print()
                    print("Library count is now \(userLibrary.count)")
                
                    let alert = UIAlertController(title: "Book found!", message: "\(titleTextField.text!) was deleted from your library", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Cool!", style: .default, handler: { (action) in
                    
                    }))
                    self.present(alert, animated: true, completion: nil)
                
                    if userLibrary.count == 0 {
                        // Set this boolean back to false and save an empty array back on the server
                        updateBoolStats(false, "didSaveFirstBook")
                        PFUser.current()!.setValue([[]], forKey: "library")
                    }
                    // Stop the loop when match is found
                    return
                } else {
                    print("No books matching that title were found. The library was unscathed")
                    let alert = UIAlertController(title: "Book not found!", message: "No books found matching the title: \(titleTextField.text!). Please check your entry and try again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Cool!", style: .default, handler: { (action) in
                    
                    }))
                    self.present(alert, animated: true, completion: nil)
                    // Stop the loop when no match is found
                    return
                }
            }
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
