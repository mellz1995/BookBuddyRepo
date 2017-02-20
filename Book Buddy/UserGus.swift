//
//  UserGus.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/10/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import Foundation
import Parse

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

func updateArray(_ changeStat: [[String]], _ key: String) {
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
func GUSUerLibrary(_ newBook: [String]){
    var userLibrary = PFUser.current()!.object(forKey: "library") as! [[String]]
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
        // Append it with the newBook array
        userLibrary.append(newBook)
        
        // Save it on the server
        updateArray(userLibrary, "library")
    }
    
    print("User library is now \(userLibrary)")
    print()
    print("User library count is now \(userLibrary.count)")
}




