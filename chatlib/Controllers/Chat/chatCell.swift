//
//  chatCell.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 16/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit

class chatCell: UITableViewCell {

    
    @IBOutlet weak var containerviewWidthconstrain: NSLayoutConstraint!
    @IBOutlet weak var chatLabel: UILabel!
    
      @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatLabel.sizeToFit()
        
        containerView.sizeToFit()

   
                 
        self.containerView.layer.cornerRadius = 7.0
        self.containerView.layer.masksToBounds = true
         chatLabel.layer.cornerRadius = 7
        
   
        self.containerView.layer.cornerRadius = 7.0
        self.containerView.layer.masksToBounds = true
        self.chatLabel.numberOfLines = 0
        self.chatLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.containerView.layer.shadowColor = UIColor.darkGray.cgColor
        self.containerView.layer.shadowColor = UIColor.darkGray.cgColor
        self.chatLabel.layer.shadowRadius = 10.0
        self.containerView.layer.shadowOpacity = 1
        
       

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
        // Configure the view for the selected state
    }

}
