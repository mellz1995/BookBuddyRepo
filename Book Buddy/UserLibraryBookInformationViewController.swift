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
        bookImage.image = bookInformationArray[7] as? UIImage
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
