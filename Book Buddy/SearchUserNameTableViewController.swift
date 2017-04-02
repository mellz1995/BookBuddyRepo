//
//  SearchUserNameTableViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/27/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse
import os.log

class SearchUserNameTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("UserInformationArray from the TableView is \(userInformationArray)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userInformationArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchUsername", for: indexPath) as? SearchUsernameCell else {
            fatalError("The dequed cell is not an instance of BooksTableViewCell")
        }

        
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2
        cell.userImage.clipsToBounds = true
        
        cell.userNameLabel.text = userInformationArray[indexPath.row][0] as? String
        cell.userImage.image = userInformationArray[indexPath.row][1] as? UIImage
        
        

        return cell
    }
    
    @IBAction func backToSearchButtonAction(_ sender: UIBarButtonItem) {
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? ""){
            case "UserInformation":
                os_log("Showing user's information", log: OSLog.default, type: .debug)
            
                guard let searchedUserInformationViewController = segue.destination as? SearchedUserInformationViewController else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                guard let selectedUserCell = sender as? SearchUsernameCell else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                guard let indexPath = tableView.indexPath(for: selectedUserCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                let selectedUser = userInformationArray[indexPath.row]
                searchedUserInformationViewController.userInforomation = selectedUser
            
            case "ViewSearchedUserLibrary":
                os_log("Viewing User's library")
            
            guard let searchedUserInformationViewController = segue.destination as? SearchedUserInformationViewController else {
                fatalError("Unexpected sender: \(String(describing: sender))")
                }
        
                guard let selectedUserCell = sender as? SearchUsernameCell else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                guard let indexPath = tableView.indexPath(for: selectedUserCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
            
                let selectedUser = userInformationArray[indexPath.row]
                searchedUserInformationViewController.userInforomation = selectedUser
            
            case "BackToSearchSeg":
                os_log("Going back to search", log: OSLog.default, type: .debug)
            
            default:
            fatalError("Unexpected Segueue Identifier: \(String(describing: segue.identifier))")
            
        }
    }
}
