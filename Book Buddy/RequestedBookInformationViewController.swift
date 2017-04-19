//
//  RequestedBookInformationViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 4/7/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

class RequestedBookInformationViewController: UIViewController {
    
    var currentRequestedLibrary = Array<Array<AnyObject>>()
    public var requestedBookInformation = Array<AnyObject>()
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbn10Label: UILabel!
    @IBOutlet weak var isbn13Label: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var cancelRequestOutlet: UIButton!
    @IBOutlet weak var requestedFromOutlet: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setEverythingUp()
        
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setEverythingUp(){
        currentRequestedLibrary = PFUser.current()!.object(forKey: "requestedLibrary") as! Array<Array<AnyObject>>
        
        requestedFromOutlet.text = "Pending request from \(requestedBookInformation[9])'s library."
        
        // Set the labels
        titleLabel.text = requestedBookInformation[0] as? String
        authorLabel.text = requestedBookInformation[1] as? String
        isbn10Label.text = requestedBookInformation[2] as? String
        isbn13Label.text = requestedBookInformation[3] as? String
        publisherLabel.text = requestedBookInformation[4] as? String
        languageLabel.text = requestedBookInformation[5] as? String
        print("Book Id?: \(requestedBookInformation[10])")
        //bookIDLabel.text = "Book id?"
        
        // Set the image of the book
        if let bookPicture = requestedBookInformation[7] as? PFFile {
            bookPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                let image = UIImage(data: imageData!)
                if image != nil {
                    self.bookImage.image = image
                }
            })
        }
    }
    
    @IBAction func cancelRequestAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Cancel Request?", message: "Cancel request to borrow '\(self.requestedBookInformation[0])'?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            
            for i in 0..<self.currentRequestedLibrary.count{
                // if the title of the book about to be deleted matches the title of the book in the user's array
                if self.currentRequestedLibrary[i][0] as! String == self.requestedBookInformation[0] as! String {
                    self.currentRequestedLibrary.remove(at: i)
                    print("MATCH FOUND! \(self.currentRequestedLibrary[i][0])")
                }
            }
            
            if self.currentRequestedLibrary.count == 0 {
                updateBoolStats(false, "didSaveFirstBook")
            }
            
            // update it on the server
            updateArray(self.currentRequestedLibrary, "requestedLibrary")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
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
