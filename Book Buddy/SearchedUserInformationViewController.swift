//
//  SearchedUserInformationViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 3/1/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

var currentUser = ""

class SearchedUserInformationViewController: UIViewController {
    
    var userLibrary = Array<Array<AnyObject>>()
    public var userInforomation = Array<AnyObject>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setEverythingUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setEverythingUp(){
        usernameLabel.text = userInforomation[0] as? String
        currentUser = (userInforomation[0] as? String)!
        userProfilePic.image = userInforomation[1] as? UIImage
        libraryCountLabel.text = "\(searcedUserLibraryArray.count) book(s) in library."
        viewUserLibraryButtonOutlet.setTitle("View \(userInforomation[0])'s library", for: [])
        
        // Disable the button to view the user's library if the count is zero. This will avoid the stupid nil error
        if searcedUserLibraryArray.count == 0 {
            viewUserLibraryButtonOutlet.isEnabled = false
        }
    }
    
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var libraryCountLabel: UILabel!
    @IBOutlet weak var requestToLinkButtonOutlet: UIButton!
    @IBOutlet weak var viewUserLibraryButtonOutlet: UIButton!
    
    @IBAction func requestToLinkButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func viewUserLibraryButtonAction(_ sender: UIButton) {
        
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
