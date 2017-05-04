//
//  ClassmateTableViewCell.swift
//  Unova
//
//  Created by iosdev on 04/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit

class ClassmateTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var nameLabelView: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
