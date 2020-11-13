//
//  receiverImgCell.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 14/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit

class receiverImgCell: UITableViewCell {
    @IBOutlet weak var receiverAttachmentView: UIView!

       @IBOutlet weak var receiverImageMsgView: UIView!
       @IBOutlet weak var receivertime: UILabel!
       @IBOutlet weak var msgReadStatus: UIImageView!
       @IBOutlet weak var singleImgView: UIImageView!
  
       @IBOutlet weak var uploadView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
