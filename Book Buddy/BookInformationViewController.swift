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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Book information array: \(bookInformationArray)")
        
        setEverythingUp()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setEverythingUp(){
        // Get the current userLibrary
        currentLibrary = PFUser.current()?.object(forKey: "library") as! Array<Array<AnyObject>>
        
        // Set the labels
        titleLabel.text = bookInformationArray[0] as? String
        authorLabel.text = bookInformationArray[1] as? String
        isbn10label.text = bookInformationArray[2] as? String
        isbn13Label.text = bookInformationArray[3] as? String
        publisherLabel.text = bookInformationArray[4] as? String
        languageLabel.text = bookInformationArray[5] as? String
        ownerLabel.text = bookInformationArray[9] as? String
        bookIDLabel.text = "\(bookInformationArray[10])"
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
    @IBOutlet weak var bookIDLabel: UILabel!
    @IBOutlet weak var imageButtonOutlet: UIButton!
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
            let uploadableImage = PFFile(data: UIImageJPEGRepresentation(image, 1.0)!)
            
            for i in 0..<currentLibrary.count {
                if currentLibrary[i][10] as! Int == bookID{
                    
                    currentLibrary[i][7] = uploadableImage! as AnyObject
                    currentLibrary[i][8] = "True" as AnyObject
                    
                    updateArray(currentLibrary, "library")
                }
            }
            
        } else {
            
        }
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        var newUserLibrary = Array<Array<AnyObject>>()
        let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete \(titleLabel.text!) from your library?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes, Delete", style: .default, handler: { (action) in
            bookID = self.bookInformationArray[10] as! Int
            
            // Loop through the userLibrary double array
            for i in 0..<self.currentLibrary.count{
                
                // If the double array at that index matches the current bookId, delete that book
                if self.currentLibrary[i][10] as! Int == bookID {
                    
                    // Remove all indexes at i
                    print(self.currentLibrary[i])
                    self.currentLibrary[i].removeAll()
                    
                    print("Current library is now \(self.currentLibrary)")
                    
                    // When a user deletes a book, the 2D array at that index is cleared. This leaves an ampty array on the server. This for loop, loops through the currentUserLibrary to find the empty index. It appends the newUserLibrary with only the indexes that are not empty
                    for i in 0..<self.currentLibrary.count {
                        if self.currentLibrary[i].isEmpty == false {
                            newUserLibrary.append(self.currentLibrary[i])
                        }
                    }
                    
                    //Update the library on the server
                    print("New User Library is \(newUserLibrary)")
                    updateArray(newUserLibrary, "library")
                    
                    // Check to see if the library is now empty.
                    print("Current Library count is \(self.currentLibrary.count)")
                    
                    if self.currentLibrary.count == 1 && self.currentLibrary[0].isEmpty {
                        // The first index is an empty array
                        updateBoolStats(false, "didSaveFirstBook")
                    }
                    
                    let alert2 = UIAlertController(title: "Book Deleted!", message: "Removed \(self.titleLabel.text!) from your library!", preferredStyle: UIAlertControllerStyle.alert)
                    alert2.addAction(UIAlertAction(title: "Great", style: .default, handler: { (action) in
                        // Send the user back to the library page
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let view = storyboard.instantiateViewController(withIdentifier: "YourLibrary")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = view
                    }))
                    self.present(alert2, animated: true, completion: nil)
                }
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No, don't delete", style: .default, handler: { (action) in
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
