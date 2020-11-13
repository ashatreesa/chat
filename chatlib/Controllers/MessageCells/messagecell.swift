//
//  messagecell.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 14/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit
class messagecell: UITableViewCell {
    @IBOutlet weak var conView : UIView!
       @IBOutlet weak var  messLabel: UILabel!
       @IBOutlet weak var tymLabel : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
              self.messLabel.numberOfLines = 0
              self.messLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
              self.messLabel.sizeToFit()
              self.conView.layer.cornerRadius = 6
              //self.conView.layer.masksToBounds = true
              self.conView.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
}
