//
//  sendercell.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 14/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit

class sendercell: UITableViewCell {
    @IBOutlet weak var senderImageView : UIImageView!
    
       @IBOutlet weak var senderTime : UILabel!
       @IBOutlet weak var messageView : UIView!
       @IBOutlet weak var usernameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
