//
//  FinalizeRequestViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 4/21/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class FinalizeRequestViewController: UIViewController {
    
    var finalRequestedBookArray = Array<AnyObject>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setEverythingUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var booktitle: UILabel!
    @IBOutlet weak var requestingFromUsername: UILabel!
    @IBOutlet weak var dataPicker: UIDatePicker!
    @IBAction func datePickerAction(_ sender: UIDatePicker) {
    }
    
    @IBOutlet weak var finalizeRequestOutlet: UIButton!
    @IBAction func finalizeRequestAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Finalize Request?", message: "Request to borrow '\(requestedBookArray[0])'?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                    // add the book to the current user's requested library
                    self.finalRequestedBookArray = requestedBookArray as Array<AnyObject>
            
                    print("The requested book is: \(self.finalRequestedBookArray)")
                    
                    // Format the data
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    let selectedDate = dateFormatter.string(from: self.dataPicker.date)
                    print("The selected date is ", selectedDate)
                    
                    // Add the date to index 11 of the finalRequestedBookArray
                    self.finalRequestedBookArray.append(selectedDate as AnyObject)
            
                    // Add the requested book to the user's requested library
                    GUSUerLibrary(self.finalRequestedBookArray as [AnyObject], "requestedLibrary", "didRequestFirstBook")
                    
                    // Add the book to the requested user's received requests array
                    
                    
                    // Clear the requestedBook array
                    requestedBookArray.removeAll()
                    self.finalRequestedBookArray.removeAll()
                    print("Requested Book Array Cleared!")
                
            }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.finalRequestedBookArray.removeAll()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setEverythingUp(){
        
        dataPicker.datePickerMode = UIDatePickerMode.date
        
        // Set the image of the book
        if let bookPicture = requestedBookArray[7] as? PFFile {
            bookPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                let image = UIImage(data: imageData!)
                if image != nil {
                    self.bookImage.image = image
                }
            })
        }
        
        booktitle.text = requestedBookArray[0] as? String
        requestingFromUsername.text = requestedBookArray[9] as? String
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
