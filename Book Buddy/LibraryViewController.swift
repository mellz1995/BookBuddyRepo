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

