//
//  SearchUsernameCell.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/27/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class SearchUsernameCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    func viewDidLayoutSubviews() {
        userImage.layer.cornerRadius = userImage.frame.size.width/2
        userImage.clipsToBounds = true
    }
    
}
