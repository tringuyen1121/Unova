//
//  CalendarTableViewCell.swift
//  Unova
//
//  Created by iosdev on 04/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var dateLabelView: UILabel!
    @IBOutlet weak var nameLabelView: UILabel!
    @IBOutlet weak var timeLabelView: UILabel!
    @IBOutlet weak var roomLabelView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
