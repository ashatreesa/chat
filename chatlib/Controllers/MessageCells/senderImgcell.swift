//
//  senderImgcell.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 14/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit

class senderImgcell: UITableViewCell {
    @IBOutlet weak var downloadView: UIView!
     @IBOutlet weak var senderAttachmentView: UIView!
  
     @IBOutlet weak var senderImageMsgView: UIView!
     @IBOutlet weak var senderTime2: UILabel!
     @IBOutlet weak var senderImageView: UIImageView!
     @IBOutlet weak var singleImgView: UIImageView!
   
     @IBOutlet weak var usernameLbl: UILabel!
     
     @IBOutlet weak var lbl: UILabel!
     
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
