//
//  ChatBaseCell.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/15.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class ChatBaseCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    public var model : MessageModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func refresh() {
        self.avatarImageView.image = UIImage.init(imageLiteralResourceName: "Avatar")
        self.contentLabel.text = self.model!.content
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
