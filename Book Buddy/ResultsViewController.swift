//
//  ResultsViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/10/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//


import UIKit

class ResultsViewController: UIViewController {
    
    var newBook = [String]()
    
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            searchingForLabel.alpha = 1
            titleLabel.alpha = 1
            authorLabel.alpha = 1
            isbn10Label.alpha = 1
            isbn13Label.alpha = 1
            langageLabel.alpha = 1
            
            titleLabel.text = "Loading..."
            authorLabel.text = "Loading..."
            isbn10Label.text = "Loading..."
            isbn13Label.text = "Loading..."
            langageLabel.text = "Loading..."
            
            searchingForLabel.text = "Searching for '\(scannedBarcode)'"
            searchScannedResult(scannedBarcode)
        }
        
        // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ResultsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Causes the view (or one of its embedded text fields) to resign the first responder status and drop into background
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var searchBox: UITextField!
    @IBOutlet weak var searchingForLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbn10Label: UILabel!
    @IBOutlet weak var isbn13Label: UILabel!
    @IBOutlet weak var langageLabel: UILabel!
    @IBOutlet weak var searchButtonOutlet: UIButton!
    @IBAction func searchButtonAction(_ sender: UIButton) {
        
        dismissKeyboard()
        
        // Start the activity spinner
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        searchingForLabel.alpha = 1
        titleLabel.alpha = 1
        authorLabel.alpha = 1
        isbn10Label.alpha = 1
        isbn13Label.alpha = 1
        langageLabel.alpha = 1
        
        titleLabel.text = "Loading..."
        authorLabel.text = "Loading..."
        isbn10Label.text = "Loading..."
        isbn13Label.text = "Loading..."
        langageLabel.text = "Loading..."
        
        searchingForLabel.text = "Searching for '\(searchBox.text!)'"
        searchScannedResult(searchBox.text!)
        
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
                                            self.newBook.append("Not specified")
                                            self.titleLabel.text = "Not specified"
                                        } else {
                                            print("Title is \(title)")
                                            self.newBook.append(title)
                                            self.titleLabel.text = title
                                        }
                                    } else {
                                        print("Error with getting title.")
                                        self.newBook.append("Not specified")
                                    }
                                    
                                    // Get the author
                                    if let authorData = data["author_data"] as? [[String: Any]]{
                                        for authorDatas in authorData {
                                            if let authorName = authorDatas["name"] as? String{
                                                if authorName.isEmpty{
                                                    print("The authorName is not specified")
                                                    self.newBook.append("Not specified")
                                                    self.authorLabel.text = "Not specified"
                                                } else {
                                                    print("Author is \(authorName)")
                                                    self.newBook.append(authorName)
                                                    self.authorLabel.text = authorName
                                                }
                                            } else {
                                                print("Error with getting Author.")
                                                self.newBook.append("Not specified")
                                            }
                                        }
                                    }
                                    
                                    // Get the ISBN10
                                    if let isbn10 = data["isbn10"] as? String{
                                        if isbn10.isEmpty {
                                            print("ISBN10 is not specified")
                                            self.newBook.append("Not specified")
                                            self.isbn10Label.text = "Not specified"
                                        } else {
                                            print("ISBN10 is \(isbn10)")
                                            self.newBook.append(isbn10)
                                            self.isbn10Label.text = isbn10
                                        }
                                    } else {
                                        print("Error with getting ISBN10.")
                                        self.newBook.append("Not specified")
                                    }
                                    
                                    // Get the ISBN13
                                    if let isbn13 = data["isbn13"] as? String{
                                        if isbn13.isEmpty {
                                            print("ISBN13 is not specified")
                                            self.newBook.append("Not specified")
                                            self.isbn13Label.text = "Not specified"
                                        } else {
                                            print("ISBN13 is \(isbn13)")
                                            self.newBook.append(isbn13)
                                            self.isbn13Label.text = isbn13
                                        }
                                    } else {
                                        print("Error with getting ISBN13.")
                                        self.newBook.append("Not specified")
                                    }
                                    
                                    // Get the publisher
                                    if let publisher = data["publisher_name"] as? String{
                                        if publisher.isEmpty {
                                            print("The publisher is not specified")
                                            self.newBook.append("Not specified")
                                        } else {
                                            print("Publisher is \(publisher)")
                                            self.newBook.append(publisher)
                                        }
                                    } else {
                                        print("Error with getting publisher.")
                                        self.newBook.append("Not specified")
                                    }
                                    
                                    // Get the langauge
                                    if let langauge = data["language"] as? String{
                                        if langauge.isEmpty{
                                            print("The language is not specified")
                                            self.newBook.append("Not specified")
                                            self.langageLabel.text = "Not specified"
                                        } else {
                                            print("Language is \(langauge)")
                                            self.newBook.append(langauge)
                                            self.langageLabel.text = langauge
                                        }
                                    } else {
                                        print("Error with getting langauge.")
                                        self.newBook.append("Not specified")
                                    }
                                    
                                    print()
                                    print("End of file!")
                                    print("newBook array is \(self.newBook)")
                                    
                                    
                                    // Add the new book to the server
                                    GUSUerLibrary(self.newBook)
                                    
                                    // Remove all contents of the newBook array
                                    self.newBook.removeAll()
                                }
                            }
                        }
                    } catch {
                        DispatchQueue.main.async(execute: {
                            print("No resutls found...")
                            self.searchingForLabel.text = "No results found..."
                            self.titleLabel.alpha = 0
                            self.authorLabel.alpha = 0
                            self.isbn10Label.alpha = 0
                            self.isbn13Label.alpha = 0
                            self.langageLabel.alpha = 0
                            
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
