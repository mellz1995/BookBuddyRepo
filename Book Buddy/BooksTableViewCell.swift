//
//  BooksTableViewCell.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/22/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class BooksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbn10Label: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var editImageButtonOutlet: UIButton!
    @IBAction func editImageButtonAction(_ sender: UIButton) {
        
    }
    
    func checkToEnableEditButton(_ editButtonIsActive: Bool){
        print("Method is getting called")
        if editButtonIsActive == false{
            editImageButtonOutlet.isEnabled = false
            editImageButtonOutlet.alpha = 0
        } else {
            editImageButtonOutlet.isEnabled = true
            editImageButtonOutlet.alpha = 1
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
