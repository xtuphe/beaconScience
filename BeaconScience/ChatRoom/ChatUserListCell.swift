//
//  ChatUserListCell.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/2/26.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class ChatUserListCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var redDot: UIView!
    
    open var model : InfoModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    open func refresh(){
        self.avatarImageView.image = UIImage.init(imageLiteralResourceName: "Avatar")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
