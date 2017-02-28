//
//  SearchUserNameTableViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/27/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class SearchUserNameTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("UserInformationArray from the TableView is \(userInformationArray)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
            cell.userNameLabel.text = userInformationArray[indexPath.row][0] as? String
            cell.userImage.image = userInformationArray[indexPath.row][1] as? UIImage
        
        

        return cell
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
