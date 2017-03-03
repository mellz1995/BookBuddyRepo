//
//  UserLibraryBookInformationViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 3/1/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class UserLibraryBookInformationViewController: UIViewController {
    
    public var bookInformationArray = Array<Any>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setEverythingUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setEverythingUp(){
        titleLabel.text = bookInformationArray[0] as? String
        authorLabel.text = bookInformationArray[1] as? String
        isbn10Label.text = bookInformationArray[2] as? String
        isbn13Label.text = bookInformationArray[3] as? String
        publisherLabel.text = bookInformationArray[4] as? String
        languageLabel.text = bookInformationArray[5] as? String
        // Set the image of the book
        if let bookPicture = bookInformationArray[7] as? PFFile {
            bookPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                let image = UIImage(data: imageData!)
                if image != nil {
                    self.bookImage.image = image
                    
                }
            })
        }
    }
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbn10Label: UILabel!
    @IBOutlet weak var isbn13Label: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var requestToBorrowBookButtonOutlet: UIButton!
    @IBAction func requestToBorrowBookButtonAction(_ sender: UIButton) {
        
        
    }
    
    @IBOutlet weak var addToWishListButtonOutlet: UIButton!
    @IBAction func addToWithListButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add book?", message: "Add \(bookInformationArray[0]) to your wish list?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            
            // Change the index of BIA to no owner since this book is being added to the wish list
            self.bookInformationArray[9] = "No owner. Wanted"
            
            // Change the ID of the book to make it relevant to the current user
            self.bookInformationArray[10] = getAndIncrementCurrentBookId() as AnyObject
            
            GUSUerLibrary(self.bookInformationArray as [AnyObject], "wishList", "didSaveFirstWishListBook")
            
            let alert2 = UIAlertController(title: "Book added!?", message: "Added \(self.bookInformationArray[0]) to your wish list?", preferredStyle: UIAlertControllerStyle.alert)
            alert2.addAction(UIAlertAction(title: "Great", style: .default, handler: { (action) in
                
                
            }))
            self.present(alert2, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "No, don't add", style: .default, handler: { (action) in
            
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
