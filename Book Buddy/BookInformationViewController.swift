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

class BookInformationViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var currentLibrary = Array<Array<AnyObject>>()
    public var bookInformationArray = Array<Any>()
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
    
    
    override func viewDidLoad() {
        
        // Check to see if the user is coming from the with list page.
        if comingFromWishList == true {
            key = "wishList"
        } else {
            key = "library"
        }
        
        bookID = self.bookInformationArray[10] as! Int
        super.viewDidLoad()
        saveButtonOutlet.isEnabled = false
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
    
    
    func setEverythingUp(){
        // Get the current userLibrary
        currentLibrary = PFUser.current()?.object(forKey: key) as! Array<Array<AnyObject>>
        
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
        
        saveButtonOutlet.setTitleColor(UIColor.blue, for: [])
    }
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    @IBAction func imageButtonAction(_ sender: UIButton) {
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
            self.saveButtonOutlet.setTitleColor(UIColor.red, for: [])
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
            saveButtonOutlet.setTitleColor(UIColor.red, for: [])
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
