//
//  receiverCell.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 14/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit

class receiverCell: UITableViewCell {

  @IBOutlet weak var containerviewWidthconstrain: NSLayoutConstraint!
    @IBOutlet weak var receiverTime : UILabel!
    @IBOutlet weak var receivrMsgView : UIView!
    @IBOutlet weak var receivermsg: UILabel!
    @IBOutlet weak var msgReadStatus : UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
       receivermsg.sizeToFit()
        receivrMsgView.sizeToFit()
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                
                
                
            }
            else {
                
                //self.contentView.backgroundColor = UIColor(red: 236, green: 229, blue: 221, alpha: 1.00)
                //receivermsg.textColor = UIColor.black
                //receiverTime.textColor = UIColor.black
                
                // receivrMsgView.backgroundColor = UIColor.white
            }
        } else {
            // Fallback on earlier versions
        }
             self.receivrMsgView.layer.cornerRadius = 7.0
             self.receivrMsgView.layer.masksToBounds = true
              receivermsg.layer.cornerRadius = 7
             
        
             self.receivrMsgView.layer.cornerRadius = 7.0
             self.receivrMsgView.layer.masksToBounds = true
             self.receivermsg.numberOfLines = 0
             self.receivermsg.lineBreakMode = NSLineBreakMode.byWordWrapping
             self.receivrMsgView.layer.shadowColor = UIColor.darkGray.cgColor
             self.receivrMsgView.layer.shadowColor = UIColor.darkGray.cgColor
             self.receivermsg.layer.shadowRadius = 10.0
             self.receivrMsgView.layer.shadowOpacity = 1
             
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        receivrMsgView.layer.cornerRadius = 5
    }

}
