//
//  TestManualEntryViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/20/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import os.log
import GoogleMobileAds

class NewBookViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var userLibrary = Array<Array<AnyObject>>()
    var newBook = [AnyObject]()
    var saveButtonTimer = Timer()
    var activityIndicator = UIActivityIndicatorView()
    var randomBookImageNumber = 0
    var image: UIImage? = nil
    var setImage = false
    var usableImage: UIImage? = nil
    var regularImage: UIImage? = nil
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.alpha = 1
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        // You have to add your app id when you register your admob account!! This is just a test ad that won't make you any money, fool
        
        //The other place you have this is in the app delegate
        bannerView.adUnitID = "ca-app-pub-9692686923892592/9608344067"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        // Start the timer to see if to enable save button or not
        startSaveButtonTimer()
        // Disable the save button until user enters a title
        saveButtonOutlet.isEnabled = false
        
        regularImage = #imageLiteral(resourceName: "QuestionMarkBook")
        bookImageView.image = #imageLiteral(resourceName: "QuestionMarkBook")
        
        // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // If the user has just returned from the scanned screen, search the scanned barcode
        if scanned {
            
            dismissKeyboard()
            
            // Start the activity spinner
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            searchScannedResult(scannedBarcode)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var isbn10TextField: UITextField!
    @IBOutlet weak var isbn13TextField: UITextField!
    @IBOutlet weak var publisherTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var bookImageView: UIImageView!
    
    @IBAction func changeBookImageButtoomAction(_ sender: UIButton) {
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
            bookImageView.image = image
            setImage = true
            usableImage = image
        } else {
            
        }
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
        self.dismissKeyboard()
        DispatchQueue.main.async {
            // Start the activity spinner
            self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            print()
        
            // Append the newBook array with the contents of the text fields
            // Check to see if the text fields are empty first! The user is not required to enter all information on a book if they wish not to do so
        
            self.newBook.append(self.titleTextField.text! as AnyObject) // This does not need to check the title text field becasue a title is required to save a book
        
            if (self.authorTextField.text?.isEmpty)!{
                self.newBook.append("Not specified" as AnyObject)
            } else {
                self.newBook.append(self.authorTextField.text! as AnyObject)
            }
        
            if (self.isbn10TextField.text?.isEmpty)!{
                self.newBook.append("Not specified" as AnyObject)
            } else {
                self.newBook.append(self.isbn10TextField.text! as AnyObject)
            }
        
            if (self.isbn13TextField.text?.isEmpty)!{
                self.newBook.append("Not specified" as AnyObject)
            } else {
                self.newBook.append(self.isbn13TextField.text! as AnyObject)
            }
        
            if (self.publisherTextField.text?.isEmpty)!{
                self.newBook.append("Not specified" as AnyObject)
            } else {
                self.newBook.append(self.publisherTextField.text! as AnyObject)
            }
        
            if (self.languageTextField.text?.isEmpty)! {
                self.newBook.append("Not specified" as AnyObject)
            } else {
                self.newBook.append(self.languageTextField.text! as AnyObject)
            }
        
            // Add a status to the book (Owned, Lent, Borrowed)
            self.newBook.append("Owned" as AnyObject)
        
        
            //Append the newBookArray with a randomly generated book image if user hasn't set an image
            if self.setImage == true {
                self.newBook.append(getPFFileVersionOfImage(self.usableImage!))
                self.newBook.append("True" as AnyObject)
            } else {
                self.newBook.append(getPFFileVersionOfImage(self.regularImage!))
                // Append the bookArray with a boolean false. This is whether or not the user has manually set an image for the book
                self.newBook.append("False" as AnyObject)
            }
        
            // Add the current user as owner of the book
            self.newBook.append(getUsername() as AnyObject)
        
            // Give the book an ID
            self.newBook.append(getAndIncrementCurrentBookId() as AnyObject)
        
            // Add the new book to the server
            GUSUerLibrary(self.newBook as [AnyObject], "library", "didSaveFirstBook")
        
            // Stop the animator
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        
            let alert = UIAlertController(title: "Book Saved!", message: "Added \(self.titleTextField.text!) to your library!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Great", style: .default, handler: { (action) in
                // Send the user back to the library page
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let view = storyboard.instantiateViewController(withIdentifier: "YourLibrary")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = view
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func startSaveButtonTimer(){
        saveButtonTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.checkSaveButton), userInfo: nil, repeats: true)
    }
    
    func checkSaveButton(){
        if (titleTextField.text?.isEmpty)!{
            saveButtonOutlet.isEnabled = false
        } else {
            saveButtonOutlet.isEnabled = true
        }
    }
    
    // This function is called when the user scans a book's barcode
    func searchScannedResult(_ searchQueary: String){
        // Remove spaces
        let noSpaces = searchQueary.replacingOccurrences(of: " ", with: "_")
        
        // Remove commas
        let noCommas = noSpaces.replacingOccurrences(of: ",", with: "")
        
        // Remove periods
        let noPeriods = noCommas.replacingOccurrences(of: ".", with: "")
        
        // Replace slashes
        let noSlashes = noPeriods.replacingOccurrences(of: "/", with: "")
        
        // Set the final search query
        let finalSearchQuery = noSlashes
        
        // Set the url with my set api key and the final search querey
        let url = URL(string: "http://isbndb.com/api/v2/json/\(mykey)/books?q=\(finalSearchQuery)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print(error!)
            } else {
                if let urlContent = data {
                    
                    do {
                        let jsonResult = try  JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        //print(jsonResult)
                        
                        // Get the title
                        if let datas = jsonResult["data"] as? [[String: Any]] {
                            
                            for data in datas {
                                DispatchQueue.main.async {
                                    // Get the title
                                    if let title = data["title"] as? String{
                                        if title.isEmpty {
                                            print("The title is not specified")
                                            self.newBook.append("Not specified" as AnyObject)
                                            self.titleTextField.text = "Not specified"
                                        } else {
                                            print("Title is \(title)")
                                            self.newBook.append(title as AnyObject)
                                            self.titleTextField.text = title
                                        }
                                    } else {
                                        print("Error with getting title.")
                                        self.newBook.append("Not specified" as AnyObject)
                                    }
                                    
                                    // Get the author
                                    if let authorData = data["author_data"] as? [[String: Any]]{
                                        for authorDatas in authorData {
                                            if let authorName = authorDatas["name"] as? String{
                                                if authorName.isEmpty{
                                                    print("The authorName is not specified")
                                                    self.newBook.append("Not specified" as AnyObject)
                                                    self.authorTextField.text = "Not specified"
                                                } else {
                                                    print("Author is \(authorName)" as AnyObject)
                                                    self.newBook.append(authorName as AnyObject)
                                                    self.authorTextField.text = authorName
                                                }
                                            } else {
                                                print("Error with getting Author." as AnyObject)
                                                self.newBook.append("Not specified" as AnyObject)
                                            }
                                        }
                                    }
                                    
                                    // Get the ISBN10
                                    if let isbn10 = data["isbn10"] as? String{
                                        if isbn10.isEmpty {
                                            print("ISBN10 is not specified")
                                            self.newBook.append("Not specified" as AnyObject)
                                            self.isbn10TextField.text = "Not specified"
                                        } else {
                                            print("ISBN10 is \(isbn10)")
                                            self.newBook.append(isbn10 as AnyObject)
                                            self.isbn10TextField.text = isbn10
                                        }
                                    } else {
                                        print("Error with getting ISBN10.")
                                        self.newBook.append("Not specified" as AnyObject)
                                    }
                                    
                                    // Get the ISBN13
                                    if let isbn13 = data["isbn13"] as? String{
                                        if isbn13.isEmpty {
                                            print("ISBN13 is not specified")
                                            self.newBook.append("Not specified" as AnyObject)
                                            self.isbn13TextField.text = "Not specified"
                                        } else {
                                            print("ISBN13 is \(isbn13)")
                                            self.newBook.append(isbn13 as AnyObject)
                                            self.isbn13TextField.text = isbn13
                                        }
                                    } else {
                                        print("Error with getting ISBN13.")
                                        self.newBook.append("Not specified" as AnyObject)
                                    }
                                    
                                    // Get the publisher
                                    if let publisher = data["publisher_name"] as? String{
                                        if publisher.isEmpty {
                                            print("The publisher is not specified")
                                            self.newBook.append("Not specified" as AnyObject)
                                            self.publisherTextField.text = "Not specified"
                                        } else {
                                            print("Publisher is \(publisher)" as AnyObject)
                                            self.newBook.append(publisher as AnyObject)
                                            self.publisherTextField.text = publisher
                                        }
                                    } else {
                                        print("Error with getting publisher.")
                                        self.newBook.append("Not specified" as AnyObject)
                                    }
                                    
                                    // Get the langauge
                                    if let langauge = data["language"] as? String{
                                        if langauge.isEmpty{
                                            print("The language is not specified")
                                            self.newBook.append("Not specified" as AnyObject)
                                            self.languageTextField.text = "Not specified"
                                        } else {
                                            print("Language is \(langauge)" as AnyObject)
                                            self.newBook.append(langauge as AnyObject)
                                            self.languageTextField.text = langauge
                                        }
                                    } else {
                                        print("Error with getting langauge.")
                                        self.newBook.append("Not specified" as AnyObject)
                                    }
                                    
                                    // Print that the book is owned since user is adding to the library
                                    self.newBook.append("Owned" as AnyObject)
                                    
                                    
                                    print()
                                    print("End of file! Newly added book is: ")
                                    
                                    //Print out the newly added book's information
                                    for i in 0..<self.newBook.count{
                                        if i == 0 {
                                            print("Title: \(self.newBook[i])")
                                        }
                                        
                                        if i == 1 {
                                            print("Author: \(self.newBook[i])")
                                        }
                                        
                                        if i == 2 {
                                            print("ISBN10: \(self.newBook[i])")
                                        }
                                        
                                        if i == 3 {
                                            print("ISBN13: \(self.newBook[i])")
                                        }
                                        
                                        if i == 4 {
                                            print("Publisher: \(self.newBook[i])")
                                        }
                                        
                                        if i == 5 {
                                            print("Language: \(self.newBook[i])")
                                        }
                                        
                                        if i == 6 {
                                            print("Status: \(self.newBook[i])")
                                        }
                                    }
                                    
                                    // Remove all contents of the newBook array
                                    self.newBook.removeAll()
                                    print("NewBookArrayCleared")
                                    
                                    scanned = false
                                    print("Scanned is now false")
                                }
                            }
                        }
                    } catch {
                        DispatchQueue.main.async(execute: {
                            print("No resutls found...")
                            
                            // In the case of a book not being found by a scanned barcode, the newBook array will get appended with a lot of "Not specified's". To prevent this being a problem, clear the newBook array
                            self.newBook.removeAll()
                        })
                    }
                }
            }
        }
        task.resume()
        stopAnimator()
    }
    
    func stopAnimator(){
        UIApplication.shared.endIgnoringInteractionEvents()
        self.activityIndicator.stopAnimating()
    }
}
