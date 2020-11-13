//
//  MessageTableViewCell.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 04/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    
    @IBOutlet weak var messageCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileImage.layer.cornerRadius = (profileImage.frame.size.height)/2
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

      
    }

}
