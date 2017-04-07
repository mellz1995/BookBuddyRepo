//
//  RequestedBookInformationViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 4/7/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
