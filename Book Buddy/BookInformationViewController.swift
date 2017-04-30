//
//  BookInformationViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/24/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse
var bookID = 0
import GoogleMobileAds

class BookInformationViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var currentLibrary = Array<Array<AnyObject>>()
    public var bookInformationArray = Array<AnyObject>()
    public var newBookInformationArray = Array<Any>() // For when the user edits something
    var checkChangeTimer = Timer()
    var titleValue = ""
    var authorValue = ""
    var isbn10Value = ""
    var isbn13Value = ""
    var publisherValue = ""
    var languageValue = ""
    var bookImageValue = UIImage()
    var imageUse = UIImage()
    var currentImage = UIImage()
    var didChangePicture = false
    var key = ""
    var originalUsername = PFUser.current()!.username
    var originalPassword = PFUser.current()!.object(forKey: "recoveryPassword")
    var secondUsername = ""
    var secondPassword = ""
    
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var bookDueLabel: UILabel!
    @IBOutlet weak var returnOutlet: UIButton!
    @IBAction func returnAction(_ sender: UIButton) {

    }
    
    
    override func viewDidLoad() {
        
        bannerView.alpha = 1
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        // You have to add your app id when you register your admob account!! This is just a test ad that won't make you any money, fool
        
        //The other place you have this is in the app delegate
        bannerView.adUnitID = "ca-app-pub-9692686923892592/9608344067"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        // Check to see if the user is coming from the with list page.
        if comingFromWishList == true {
            key = "wishList"
        } else {
            key = "library"
        }
        
        bookID = self.bookInformationArray[10] as! Int
        super.viewDidLoad()
        saveButtonOutlet.isEnabled = false
        saveButtonOutlet.setImage(#imageLiteral(resourceName: "SaveBlue"), for: [])
        startDidChangeTimer()

        print("Book information array: \(bookInformationArray)")
        
        setEverythingUp()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Causes the view (or one of its embedded text fields) to resign the first responder status and drop into background
    func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBOutlet weak var changeButtonOutlet: UIButton!
    
    
    func setEverythingUp(){
        // Get the current userLibrary
        
        if libraryMode == "borrowed" || libraryMode == "lent" {
            
            
            // Change text field images
            titleTextFieldImage.image = #imageLiteral(resourceName: "BookNoPencilTextField")
            authorTextFieldImage.image = #imageLiteral(resourceName: "BookNoPencilTextField")
            isbn10TextFieldImage.image = #imageLiteral(resourceName: "BookNoPencilTextField")
            isbn13TextFieldImage.image = #imageLiteral(resourceName: "BookNoPencilTextField")
            publisherTextFieldImage.image = #imageLiteral(resourceName: "BookNoPencilTextField")
            languageTextFieldImage.image = #imageLiteral(resourceName: "BookNoPencilTextField")
            
            // Disable the text fields
            titleTextField.isEnabled = false
            authorTextField.isEnabled = false
            isbn10TextField.isEnabled = false
            isbn13TextField.isEnabled = false
            publisherTextField.isEnabled = false
            lanuguageTextField.isEnabled = false
            
            // Disable the save and clear button
            saveButtonOutlet.isEnabled = false
            saveButtonOutlet.alpha = 0
            clearButtonOutlet.isEnabled = false
            clearButtonOutlet.alpha = 0
            
            if libraryMode == "borrowed" {
                currentLibrary = PFUser.current()?.object(forKey: "borrowedBooks") as! Array<Array<AnyObject>>
                // Change the 'Change' button to 'Return'
                changeButtonOutlet.setImage(#imageLiteral(resourceName: "ReturnButton"), for: [])
                
                returnOutlet.isEnabled = true
                returnOutlet.alpha = 1
                
            } else if libraryMode == "lent" {
                currentLibrary = PFUser.current()?.object(forKey: "lentBooks") as! Array<Array<AnyObject>>
                changeButtonOutlet.isEnabled = false
                changeButtonOutlet.alpha = 0
                
                let wait = DispatchTime.now() + 0.3
                DispatchQueue.main.asyncAfter(deadline: wait) {
                    if self.bookInformationArray.count > 11 {
                        if self.bookInformationArray[13] as! String == "Claim Returned" {
                            let alert = UIAlertController(title: "Book is Claimed Returned!", message: "\(self.bookInformationArray[12]) claimed they returned '\(self.bookInformationArray[0])'.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Confirm Return", style: .default, handler: { (action) in
                                
                                
                                // Remove the book from the current user's lent books
                                for i in 0..<self.currentLibrary.count {
                                    if self.currentLibrary[i][0] as! String == self.bookInformationArray[0] as! String{
                                        print("Deletion match found! Book: \(self.currentLibrary[i][0])")
                                        print("\(self.currentLibrary[i]) will be removed.")
                                        self.currentLibrary.remove(at: i)
                                        print("Borrowed library's count is now \(self.currentLibrary.count)")
                                    }
                                }
                                
                                // If the count of the current user's borrowed library is 0, insert false into the 'lentFirstBook
                                if self.currentLibrary.count == 0 {
                                    updateBoolStats(false, "lentFirstBook")
                                }
                                
                                // Set the lent library on the server here
                                updateArray(self.currentLibrary, "lentBooks")
                                
                                /** BEGIN THE LONG PROCESS **/
                                let query = PFUser.query()
                                query?.findObjectsInBackground { (objects, error) in
                                    if let users = objects {
                                        for object in users {
                                            if let user = object as? PFUser {
                                                if (user.username?.contains(self.bookInformationArray[12] as! String))!{
                                                    
                                                    let wait1 = DispatchTime.now() + 1.0
                                                    DispatchQueue.main.asyncAfter(deadline: wait1) {
                                                        // Logout the initial current user
                                                        PFUser.logOut()
                                                        print("The initial user (\(self.originalUsername!)) was logged out...")
                                                        
                                                        let wait = DispatchTime.now() + 0.5
                                                        DispatchQueue.main.asyncAfter(deadline: wait) {
                                                            // Login the user that the initial current user is requesting the book from
                                                            PFUser.logInWithUsername(inBackground: user.username!, password: user.object(forKey: "recoveryPassword") as! String, block: { (user, error) in
                                                                if error != nil {
                                                                    
                                                                } else {
                                                                    print("Success! Second user (\(PFUser.current()!.username!)) is logged in.")
                                                                    self.secondUsername = PFUser.current()!.username!
                                                                    
                                                                    // Delete the book from the second user's borrowed liss
                                                                    var secondUserBorrowedLibrary = PFUser.current()!.object(forKey: "borrowedBooks") as! Array<Array<AnyObject>>
                                                                    
                                                                    for i in 0..<secondUserBorrowedLibrary.count {
                                                                        if secondUserBorrowedLibrary[i][0] as! String == self.bookInformationArray[0] as! String{
                                                                            print("Second match delition found! Book: \(secondUserBorrowedLibrary[i][0])")
                                                                            print("\(secondUserBorrowedLibrary[i]) will be removed")
                                                                            secondUserBorrowedLibrary.remove(at: i)
                                                                        }
                                                                    }
                                                                    
                                                                    // If the second user's borrowed library count is now zero, update the boolean to false for borrowedFirstBook
                                                                    print("Second user's borrowed library count is \(secondUserBorrowedLibrary.count)")
                                                                    
                                                                    if secondUserBorrowedLibrary.count == 0 {
                                                                        updateBoolStats(false, "borrowedFirstBook")
                                                                    }
                                                                    
                                                                    updateArray(secondUserBorrowedLibrary, "borrowedBooks")
                                                                    
                                                                    
                                                                    
                                                                    let wait = DispatchTime.now() + 1.0
                                                                    DispatchQueue.main.asyncAfter(deadline: wait) {
                                                                        PFUser.logOut()
                                                                        print("The second user (\(self.secondUsername)) is logged out..")
                                                                        
                                                                        let wait3 = DispatchTime.now() + 1.5
                                                                        DispatchQueue.main.asyncAfter(deadline: wait3){
                                                                            print("Attempting to log back in the original current user")
                                                                            PFUser.logInWithUsername(inBackground: self.originalUsername!, password: self.originalPassword as! String, block: { (user, error) in
                                                                                if error != nil {
                                                                                    
                                                                                } else {
                                                                                    print("Success! The original user (\(PFUser.current()!.username!)) is logged back in.")
                                                                                    
                                                                                    print("The process is complete!")
                                                                                }
                                                                            })
                                                                        }
                                                                    }
                                                                }
                                                                
                                                            })
                                                        }
                                                    }
                                                    
                                                } else {
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }))
                            
                            alert.addAction(UIAlertAction(title: "Deny Return", style: .destructive, handler: { (action) in
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        } else {
            currentLibrary = PFUser.current()?.object(forKey: key) as! Array<Array<AnyObject>>
            titleTextFieldImage.image = #imageLiteral(resourceName: "BookTextfield")
            authorTextFieldImage.image = #imageLiteral(resourceName: "BookTextfield")
            isbn10TextFieldImage.image = #imageLiteral(resourceName: "BookTextfield")
            isbn13TextFieldImage.image = #imageLiteral(resourceName: "BookTextfield")
            publisherTextFieldImage.image = #imageLiteral(resourceName: "BookTextfield")
            languageTextFieldImage.image = #imageLiteral(resourceName: "BookTextfield")
            
            titleTextField.isEnabled = true
            authorTextField.isEnabled = true
            isbn10TextField.isEnabled = true
            isbn13TextField.isEnabled = true
            publisherTextField.isEnabled = true
            lanuguageTextField.isEnabled = true
            
            saveButtonOutlet.isEnabled = true
            saveButtonOutlet.alpha = 1
            clearButtonOutlet.isEnabled = true
            clearButtonOutlet.alpha = 1
            changeButtonOutlet.isEnabled = true
            changeButtonOutlet.alpha = 1
            
            bookDueLabel.alpha = 0
            returnOutlet.isEnabled = false
            returnOutlet.alpha = 0
        }
        
        // Set the textFields
        titleTextField.text = bookInformationArray[0] as? String
        titleValue = (bookInformationArray[0] as? String)!
        authorTextField.text = bookInformationArray[1] as? String
        authorValue = (bookInformationArray[1] as? String)!
        isbn10TextField.text = bookInformationArray[2] as? String
        isbn10Value = (bookInformationArray[2] as? String)!
        isbn13TextField.text = bookInformationArray[3] as? String
        isbn13Value = (bookInformationArray[3] as? String)!
        publisherTextField.text = bookInformationArray[4] as? String
        publisherValue = (bookInformationArray[4] as? String)!
        lanuguageTextField.text = bookInformationArray[5] as? String
        languageValue = (bookInformationArray[5] as? String)!
        ownerLabel.text = "Owner: \(bookInformationArray[9])"
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

    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbn10label: UILabel!
    @IBOutlet weak var isbn13Label: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    
    @IBOutlet weak var titleTextFieldImage: UIImageView!
    @IBOutlet weak var authorTextFieldImage: UIImageView!
    @IBOutlet weak var isbn10TextFieldImage: UIImageView!
    @IBOutlet weak var isbn13TextFieldImage: UIImageView!
    @IBOutlet weak var publisherTextFieldImage: UIImageView!
    @IBOutlet weak var languageTextFieldImage: UIImageView!
   
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var isbn10TextField: UITextField!
    @IBOutlet weak var isbn13TextField: UITextField!
    @IBOutlet weak var publisherTextField: UITextField!
    @IBOutlet weak var lanuguageTextField: UITextField!
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        // Loop through current userLibrary until you get to the index that matches the book ID
        for i in 0..<currentLibrary.count {
            if currentLibrary[i][10] as! Int == bookID{
                currentLibrary[i][0] = titleTextField.text as AnyObject
                currentLibrary[i][1] = authorTextField.text as AnyObject
                currentLibrary[i][2] = isbn10TextField.text as AnyObject
                currentLibrary[i][3] = isbn13TextField.text as AnyObject
                currentLibrary[i][4] = publisherTextField.text as AnyObject
                currentLibrary[i][5] = lanuguageTextField.text as AnyObject
                if didChangePicture == true {
                    currentLibrary[i][7] = getPFFileVersionOfImage(imageUse)
                    currentLibrary[i][8] = "True" as AnyObject
                }
                updateArray(currentLibrary, key)
            }
        }
        
        
        let alert = UIAlertController(title: "Changes Saved!", message: "Your changes were saved successfully.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Great", style: .default, handler: { (action) in
            // Send the user back to the appropriate page
            if comingFromWishList == true {
                comingFromWishList = false
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let view = storyboard.instantiateViewController(withIdentifier: "WishListViewController")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = view
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let view = storyboard.instantiateViewController(withIdentifier: "YourLibrary")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = view
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
        //saveButtonOutlet.setTitleColor(UIColor.blue, for: [])
        saveButtonOutlet.setImage(#imageLiteral(resourceName: "SaveBlue"), for: [])
    }
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    @IBAction func imageButtonAction(_ sender: UIButton) {
        
        if libraryMode == "owned" {
            bookID = self.bookInformationArray[10] as! Int
            let alert = UIAlertController(title: "From where?", message: "Take a picture or use one from your photo library?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
                imagePickerController.allowsEditing = false
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePickerController.allowsEditing = false
                self.present(imagePickerController, animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else if libraryMode == "borrowed" {
            let alert = UIAlertController(title: "Return book?", message: "Return '\(bookInformationArray[0])' to \(bookInformationArray[9])?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                /* LOGIC TO MARK A BOOK AS 'CLAIMED RETURNED
                    Append the book at index 13 to 'Claim Returned'
                    Add the newly book in place of the book in the user's current library
                    Do the same to the owner of the book
                */
                
                // Set the book at index 12 to be 'Claimed Returned'
                if self.bookInformationArray.count == 12 {
                    self.bookInformationArray[13] = "Claim Returned" as AnyObject
                    print("Saved ya there, boss")
                } else {
                    self.bookInformationArray.append("Claim Returned" as AnyObject)
                    print("First time for everything")
                }
                
                // Set the currentLibrary
                for i in 0..<self.currentLibrary.count {
                    if self.currentLibrary[i][0] as! String == self.bookInformationArray[0] as! String {
                        print("Match found! Book: \(self.currentLibrary[i][0])")
                        self.currentLibrary[i] = (self.bookInformationArray as AnyObject) as! Array<AnyObject>
                    }
                }
                
                // Save the library to the current user's borrowed books library
                updateArray(self.currentLibrary, "borrowedBooks")
                
                /** BEGIN THE LONG PROCESS **/
                let query = PFUser.query()
                query?.findObjectsInBackground { (objects, error) in
                    if let users = objects {
                        for object in users {
                            if let user = object as? PFUser {
                                if (user.username?.contains(self.bookInformationArray[9] as! String))!{
                   
                                    let wait1 = DispatchTime.now() + 1.0
                                    DispatchQueue.main.asyncAfter(deadline: wait1) {
                                        // Logout the initial current user
                                        PFUser.logOut()
                                        print("The initial user (\(self.originalUsername!)) was logged out...")
                                        
                                        let wait = DispatchTime.now() + 0.5
                                        DispatchQueue.main.asyncAfter(deadline: wait) {
                                            // Login the user that the initial current user is requesting the book from
                                            PFUser.logInWithUsername(inBackground: user.username!, password: user.object(forKey: "recoveryPassword") as! String, block: { (user, error) in
                                                if error != nil {
                                                    
                                                } else {
                                                    print("Success! Second user (\(PFUser.current()!.username!)) is logged in.")
                                                    self.secondUsername = PFUser.current()!.username!
                                                    
                                                    // Update the second user's lent librry with the newly edited book
                                                    var secondUserLentLibrary = PFUser.current()!.object(forKey: "lentBooks") as! Array<Array<AnyObject>>
                                                    
                                                    for i in 0..<secondUserLentLibrary.count {
                                                        if secondUserLentLibrary[i][0] as! String == self.bookInformationArray[0] as! String{
                                                            print("Second match found! Book: \(secondUserLentLibrary[i][0])")
                                                            secondUserLentLibrary[i] = self.bookInformationArray
                                                        }
                                                    }
                                                    
                                                    //Save it on the server
                                                    updateArray(secondUserLentLibrary, "lentBooks")
                                                    
                                                    
                                                    
                                                    let wait = DispatchTime.now() + 1.0
                                                    DispatchQueue.main.asyncAfter(deadline: wait) {
                                                        PFUser.logOut()
                                                        print("The second user (\(self.secondUsername)) is logged out..")
                                                        
                                                        let wait3 = DispatchTime.now() + 1.5
                                                        DispatchQueue.main.asyncAfter(deadline: wait3){
                                                            print("Attempting to log back in the original current user")
                                                            PFUser.logInWithUsername(inBackground: self.originalUsername!, password: self.originalPassword as! String, block: { (user, error) in
                                                                if error != nil {
                                                                    
                                                                } else {
                                                                    print("Success! The original user (\(PFUser.current()!.username!)) is logged back in.")
                                                                    
                                                                    print("The process is complete!")
                                                                }
                                                            })
                                                        }
                                                    }
                                                }
                                                
                                            })
                                        }
                                    }
                                    
                                } else {
                                    
                                }
                            }
                        }
                    }
                }
                
                let alert2 = UIAlertController(title: "One thing...", message: "\(self.bookInformationArray[9]) will have to approve that '\(self.bookInformationArray[0])' was returned.", preferredStyle: UIAlertControllerStyle.alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                    
                }))
                self.present(alert2, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            bookImage.image = image
            didChangePicture = true
            imageUse = image
        } else {
            
        }
        self.dismiss(animated: true) {
            self.saveButtonOutlet.isEnabled = true
           // self.saveButtonOutlet.setTitleColor(UIColor.red, for: [])
            self.saveButtonOutlet.setImage(#imageLiteral(resourceName: "SaveRed"), for: [])
        }
    }
    
    @IBAction func clearImageButtonAction(_ sender: UIButton) {
        bookImage.image = #imageLiteral(resourceName: "QuestionMarkBook")
        for i in 0..<currentLibrary.count {
            if currentLibrary[i][10] as! Int == bookID{
                
                didChangePicture = true
                currentLibrary[i][7] = getPFFileVersionOfImage(#imageLiteral(resourceName: "QuestionMarkBook")) as AnyObject
                currentLibrary[i][8] = "False" as AnyObject
                
                updateArray(currentLibrary, key)
            }
        }
    }
    
    func startDidChangeTimer(){
        checkChangeTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.checkSaveButton), userInfo: nil, repeats: true)
    }
    
    func checkSaveButton(){
        if titleTextField.text != titleValue || authorTextField.text != authorValue || isbn10TextField.text != isbn10Value || isbn13TextField.text != isbn13Value || publisherTextField.text != publisherValue || lanuguageTextField.text != languageValue{
            saveButtonOutlet.isEnabled = true
            //saveButtonOutlet.setTitleColor(UIColor.red, for: [])
            saveButtonOutlet.setImage(#imageLiteral(resourceName: "SaveRed"), for: [])
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
