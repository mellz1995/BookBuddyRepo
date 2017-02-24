//
//  UserGus.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/10/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import Foundation
import Parse

var randomBookImageNumber = 0
var newBookImage: PFFile? = nil
var foundEmptyIndex = false


// This class's purpose is to update all of the user's stats in one place. This is done to reduce code redundancy

func updateIntStats(_ changeStat: Int, _ key: String) {
    var currentStat = PFUser.current()?.object(forKey: key) as! Int
    currentStat += changeStat
    PFUser.current()?.setValue(currentStat, forKey: key)
    
    // Save User Variables
    PFUser.current()?.saveInBackground(block: { (success, error) in
        if error != nil {
            print("Error with saving \(key)")
        }
        else {
            print("Successfully saved \(key)")
        }
    })
}

func updateBoolStats(_ changeStat: Bool, _ key: String) {
    PFUser.current()?.setValue(changeStat, forKey: key)
    
    // Save User Variables
    PFUser.current()?.saveInBackground(block: { (success, error) in
        if error != nil {
            print("Error with saving \(key)")
        }
        else {
            print("Successfully saved \(key)")
        }
    })
}

func updateProfilePic(_ changeStat: PFFile, _ key: String) {
    PFUser.current()?.setValue(changeStat, forKey: key)
    
    // Save User Variables
    PFUser.current()?.saveInBackground(block: { (success, error) in
        if error != nil {
            print("Error with saving \(key)")
        }
        else {
            print("Successfully saved \(key)")
        }
    })
}

func updateArray(_ changeStat: Array<Array<AnyObject>>, _ key: String) {
    PFUser.current()?.setValue(changeStat, forKey: key)
    
    // Save User Variables
    PFUser.current()?.saveInBackground(block: { (success, error) in
        if error != nil {
            print("Error with saving \(key)")
        }
        else {
            print("Successfully saved \(key)")
        }
    })
}

// This gets the userLibrary, appends it, and sets it if the user scan's a new book. This method is needed because when parse is imported it messes with the subricts and json data gets funky
func GUSUerLibrary(_ newBook: [AnyObject]){
    var userLibrary = PFUser.current()!.object(forKey: "library") as! Array<Array<AnyObject>>
    print()
    print("Current library is \(userLibrary)")
    
    // Check to see if userLibrary is empty
    if PFUser.current()!.object(forKey: "didSaveFirstBook") as! Bool == false {
        print()
        print("User library is empty")
        
        // Clear the empty array
        userLibrary.removeAll()
        
        // Append the new book
        userLibrary.append(newBook)
        
        // Save it to the server
        updateArray(userLibrary, "library")
        
        // Update boolean stat to true
        updateBoolStats(true, "didSaveFirstBook")
        
    } else {
        print("User library is not empty")
        
        userLibrary.append(newBook)
        updateArray(userLibrary, "library")
    }
    
    print("User library is now \(userLibrary)")
    print()
    print("User library count is now \(userLibrary.count)")
}

func getUsername() -> String{
    let userName = PFUser.current()?.username
    return userName!
}

func getBookImageRegular() -> UIImage {
    var returnableImage: UIImage? = nil
    // Append the newBookArray with a random book image
    randomBookImageNumber = Int(arc4random_uniform(5))
    
    if randomBookImageNumber == 0 {
        returnableImage = #imageLiteral(resourceName: "BlueBookImage")
    }
    
    if randomBookImageNumber == 1 {
        returnableImage = #imageLiteral(resourceName: "RedBookImage")
    }
    
    if randomBookImageNumber == 2 {
        returnableImage = #imageLiteral(resourceName: "PurpleBookImage")
    }
    
    if randomBookImageNumber == 3 {
        returnableImage = #imageLiteral(resourceName: "YellowBookImage")
    }
    
    if randomBookImageNumber == 4 {
        returnableImage = #imageLiteral(resourceName: "GreenBookImage")
    }
    
    if randomBookImageNumber == 5 {
        returnableImage = #imageLiteral(resourceName: "OrangeBookImage")
    }
    
    return returnableImage!
}

func getBookImage() -> PFFile{
    // Converts all images into PFFfiles
    let redImage = PFFile(data: UIImageJPEGRepresentation(#imageLiteral(resourceName: "RedBookImage"), 1.0)!)
    let blueImage = PFFile(data: UIImageJPEGRepresentation(#imageLiteral(resourceName: "BlueBookImage"), 1.0)!)
    let purpleImage = PFFile(data: UIImageJPEGRepresentation(#imageLiteral(resourceName: "PurpleBookImage"), 1.0)!)
    let yellowImage = PFFile(data: UIImageJPEGRepresentation(#imageLiteral(resourceName: "YellowBookImage"), 1.0)!)
    let greenImage = PFFile(data: UIImageJPEGRepresentation(#imageLiteral(resourceName: "GreenBookImage"), 1.0)!)
    let orangeImage = PFFile(data: UIImageJPEGRepresentation(#imageLiteral(resourceName: "OrangeBookImage"), 1.0)!)
    
    
    // Append the newBookArray with a random book image
    randomBookImageNumber = Int(arc4random_uniform(5))
    
    if randomBookImageNumber == 0 {
        newBookImage = blueImage
    }
    
    if randomBookImageNumber == 1 {
        newBookImage = redImage
    }
    
    if randomBookImageNumber == 2 {
        newBookImage = purpleImage
    }
    
    if randomBookImageNumber == 3 {
        newBookImage = yellowImage
    }
    
    if randomBookImageNumber == 4 {
        newBookImage = greenImage
    }
    
    if randomBookImageNumber == 5 {
        newBookImage = orangeImage
    }
    
    return newBookImage!
}

func getAndIncrementCurrentBookId() -> Int{
    // Get the current book ID
    var currentBookId = PFUser.current()!.object(forKey: "CurrentBookId") as! Int
    // Increment the current book ID
        currentBookId += 1
    // Set the current booo ID
    updateIntStats(1, "CurrentBookId")
    print("Set book id")
    return currentBookId
}

func getPFFileVersionOfImage(_ image: UIImage) -> PFFile {
    let uploadableImage = PFFile(data: UIImageJPEGRepresentation(image, 1.0)!)
    return uploadableImage!
}




