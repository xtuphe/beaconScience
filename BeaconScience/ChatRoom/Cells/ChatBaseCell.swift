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
    
    var model : MessageModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

    }

    func refresh() {
        self.avatarImageView.image = UIImage.init(named: "Testor")
        self.contentLabel.text = self.model!.content
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

    }
    
}
