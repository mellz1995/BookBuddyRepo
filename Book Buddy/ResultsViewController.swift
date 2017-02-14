//
//  ResultsViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/10/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    
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
                        if let title = ((jsonResult["data"] as? NSArray)?[0] as? NSDictionary)?["title"] as? String{
                            DispatchQueue.main.async(execute: {
                                if title == "" {
                                    print("Title not specified")
                                    self.titleLabel.text = "Not specified"
                                } else {
                                    print("Title is \(title)")
                                    self.titleLabel.text = title
                                }
                            })
                        } else {
                            print("Error with getting title")
                        }
                        
                        // Get the author
                        if ((jsonResult["data"] as? NSArray)?[0] as? NSDictionary)?["aurhot_data"] as? String == ""{
                                print("There is no author data")
                        } else {
                            if let author = ((((jsonResult["data"] as? NSArray)?[0] as? NSDictionary)?["author_data"] as? NSArray)?[0] as? NSDictionary)?["name"] as? String{
                                DispatchQueue.main.async(execute: {
                                    if author == "" {
                                        print("Author not specified")
                                        self.authorLabel.text = "Not specified"
                                    } else {
                                        print("Author is \(author)")
                                        self.authorLabel.text = author
                                    }
                                })
                                
                            } else {
                                print("Error with getting author")
                            }
                        }
                        
                        // Get the ISBN 10
                        if let isbn10 = ((jsonResult["data"] as? NSArray)?[0] as? NSDictionary)?["isbn10"] as? String{
                            DispatchQueue.main.async(execute: {
                                if isbn10 == "" {
                                    print("ISBN10 not specified")
                                    self.isbn10Label.text = "Not specified"
                                } else {
                                    print("ISBN10 is \(isbn10)")
                                    self.isbn10Label.text = isbn10
                                }
                            })
                        } else {
                            print("Error with getting ISBN10")
                        }
                        
                        // Get the ISBN 13
                        if let isbn13 = ((jsonResult["data"] as? NSArray)?[0] as? NSDictionary)?["isbn13"] as? String{
                            DispatchQueue.main.async(execute: {
                                if isbn13 == "" {
                                    print("ISBN13 not specified")
                                    self.isbn13Label.text = "Not specified"
                                } else {
                                    print("ISBN13 is \(isbn13)")
                                    self.isbn13Label.text = isbn13
                                }
                            })
                        } else {
                            print("Error with getting ISBN13")
                        }
                        
                        // Get the language
                        if let language = ((jsonResult["data"] as? NSArray)?[0] as? NSDictionary)?["language"] as? String{
                            DispatchQueue.main.async(execute: {
                                if language == "" {
                                    print("Language not specified")
                                    self.langageLabel.text = "Not specified"
                                } else {
                                    print("Language is \(language)")
                                    self.langageLabel.text = language
                                }
                            })
                        } else {
                            print("Error with getting Language")
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
