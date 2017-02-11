//
//  SearchAPI.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/10/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

// This class's purpose is to search the api for a book result

import Foundation

let mykey = "BHPQT1PV"
var result = ""


// This function is called when the user scans a book's barcode
func searchScannedResult(_ isbn: String){
    let url = URL(string: "http://isbndb.com/api/v2/json/\(mykey)/books?q=\(isbn)")
    let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
        
        if error != nil {
            print(error!)
        } else {
            if let urlContent = data {
                
                do {
                    let jsonResult = try  JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                print(jsonResult)
                } catch {
                    print("JSON Processing failed.")
                }
            }
        }
        
    }
    
    task.resume()
}
