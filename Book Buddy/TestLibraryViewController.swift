//
//  TestLibraryViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/21/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class TestLibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var libraryTitleLabel: UILabel!
    var userLibrary = [[String]]()
    
    @IBAction func addBookButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add?", message: "Would you like to add manually or scan a book's barcode?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Manually", style: .default, handler: { (action) in
            // Send the user to the manual entry page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewController(withIdentifier: "ManualEntry")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = view
        }))
        
        alert.addAction(UIAlertAction(title: "Scan book's barcode", style: .default, handler: { (action) in
            // Send the user to the barcode scanner page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewController(withIdentifier: "Scan")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = view
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Gets the number of rows in the section
        return userLibrary.count
    }

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        
        // This displays the user's library on the table view. Index 0 is the book title
        cell.textLabel?.text = userLibrary[indexPath.row][0]
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let username = PFUser.current()?.username
        libraryTitleLabel.text = "\(username!)'s library"
        
        // Get the current userLibrary
        userLibrary = PFUser.current()!.object(forKey: "library") as! [[String]]
        print()
        print("Current library is \(userLibrary)")
        if userLibrary.count > 1 {
            print("Currently \(userLibrary.count) books in the user's library.")
        } else if userLibrary.count == 1 {
            print("Currently \(userLibrary.count) book in the user's library.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
