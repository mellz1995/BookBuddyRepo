//
//  DeletedBookInformationViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/26/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class DeletedBookInformationViewController: UIViewController {
    
    var currentLibrary = Array<Array<AnyObject>>()
    public var bookInformationArray = Array<Any>()
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbn10Label: UILabel!
    @IBOutlet weak var isbn13Label: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setEverythingUp()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setEverythingUp(){
        bookID = self.bookInformationArray[10] as! Int
        print("Book information array: \(bookInformationArray)")
        
        // Get the current userLibrary
        currentLibrary = PFUser.current()?.object(forKey: "deletedLibrary") as! Array<Array<AnyObject>>
        
        // Set the textFields
        tittleLabel.text = bookInformationArray[0] as? String
        authorLabel.text = bookInformationArray[1] as? String
        isbn10Label.text = bookInformationArray[2] as? String
        isbn13Label.text = bookInformationArray[3] as? String
        publisherLabel.text = bookInformationArray[4] as? String
        languageLabel.text = bookInformationArray[5] as? String
        print("Book Id?: \(bookInformationArray[10])")
        //bookIDLabel.text = "Book id?"
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
