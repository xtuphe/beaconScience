//
//  ChatChosenCell.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/20.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class ChatChosenCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var model : MessageModel? {
        didSet{
            refresh()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func refresh() {
        contentLabel.text = model!.content
        avatarImageView.image = UIImage.init(named: "BeaconNight")
    }
    
    
}
