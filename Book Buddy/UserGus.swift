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




