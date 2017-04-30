//
//  LibraryViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/15/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

/*
 The purpose of this class is for a user to store books in their 'library'. It uses a multi-d array
 
 Example: userLibrary[1][0] would be the title of the second book
 The first index will be like 'book information' that contains the title, author, isbn10-13, publisher and language.
 The second index are as follows:
 0 Title
 1 Author
 2 isbn10
 3 isbn13
 4 publisher
 5 lanugage
 6 status (owner, borrowed, lent)
 7 ImageFile
 8 Boolean whether the user has manually set an image for the book
 9 Owner of the book
 10 Book Id
 11 Date of the book requested to be borrowed
 12 The user that's requesting to borrow the book
 13 The book is claimed returned
 */


/*
 INFORMATION ON THE SEARCH FOR USERS ARRAY
 0 username
 1 profile picture
 2 userID
 3 didAddFirstBook
 4 isLibraryPrivate
 */


/* 
  INFORMATION ON THE LINKS ARRAY'S INDEXES
 0 User ID
 1 Username
 2 User's photo
 */


/**
    HOW TO GET, APPEND, AND SET A 2D ARRAY TO THE PARSE SERVER
 1. Get the current userLibrary from the server
    set the userLibrary variable = to the the library variable on the server. Don't forget to add 'as! [[String]] at the end of it
 2. append userLibrary with an array that has 5 indexes as denoted above
 3. use the function in user gus to add the book to the parse server online
 
 If this isn't enough information, refer to the code in Notes at the bottom of 'Links for Senior Project' and also at the bottom of this page
 
 **/



    /**
     // Adding another book to the userLibrary
     userLibrary = PFUser.current()!.object(forKey: "library") as! [[String]]
     print("Current userLibrary is \(userLibrary)")
     
     print()
     
     // Count of the userLibrary. Should get 1
     print(userLibrary.count)
     
     print()
     
     // Append one book
     book.append("Grocery")
     book.append("Melvin")
     book.append("0987654321")
     book.append("0987654321234")
     book.append("MajorBeatsProductions")
     book.append("English")
     
     userLibrary.append(book)
     
     print("The new count of userLibrary is: \(userLibrary.count)")
     
     print()
     
     print("The title of the socond book is \(userLibrary[1][0]) and the author is \(userLibrary[1][1])")
     print("Language is \(userLibrary[1][5])")
 
 **/




/** HOW TO DELETE A BOOK THE OLD FASHION WAY
 @IBAction func deleteButtonAction(_ sender: UIButton) {
 var newUserLibrary = Array<Array<AnyObject>>()
 let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete \(titleLabel.text!) from your library?", preferredStyle: UIAlertControllerStyle.alert)
 alert.addAction(UIAlertAction(title: "Yes, Delete", style: .default, handler: { (action) in
 bookID = self.bookInformationArray[10] as! Int
 
 // Loop through the userLibrary double array
 for i in 0..<self.currentLibrary.count{
 
 // If the double array at that index matches the current bookId, delete that book
 if self.currentLibrary[i][10] as! Int == bookID {
 
 // Remove all indexes at i
 print(self.currentLibrary[i])
 self.currentLibrary[i].removeAll()
 
 print("Current library is now \(self.currentLibrary)")
 
 // When a user deletes a book, the 2D array at that index is cleared. This leaves an ampty array on the server. This for loop, loops through the currentUserLibrary to find the empty index. It appends the newUserLibrary with only the indexes that are not empty
 for i in 0..<self.currentLibrary.count {
 if self.currentLibrary[i].isEmpty == false {
 newUserLibrary.append(self.currentLibrary[i])
 }
 }
 
 //Update the library on the server
 print("New User Library is \(newUserLibrary)")
 updateArray(newUserLibrary, "library")
 
 // Check to see if the library is now empty.
 print("Current Library count is \(self.currentLibrary.count)")
 
 if self.currentLibrary.count == 1 && self.currentLibrary[0].isEmpty {
 // The first index is an empty array
 updateBoolStats(false, "didSaveFirstBook")
 }
 
 let alert2 = UIAlertController(title: "Book Deleted!", message: "Removed \(self.titleLabel.text!) from your library!", preferredStyle: UIAlertControllerStyle.alert)
 alert2.addAction(UIAlertAction(title: "Great", style: .default, handler: { (action) in
 // Send the user back to the library page
 let storyboard = UIStoryboard(name: "Main", bundle: nil)
 let view = storyboard.instantiateViewController(withIdentifier: "YourLibrary")
 let appDelegate = UIApplication.shared.delegate as! AppDelegate
 appDelegate.window?.rootViewController = view
 }))
 self.present(alert2, animated: true, completion: nil)
 }
 
 }
 }))
 
 alert.addAction(UIAlertAction(title: "No, don't delete", style: .default, handler: { (action) in
 }))
 self.present(alert, animated: true, completion: nil)
 
 }
 **/

