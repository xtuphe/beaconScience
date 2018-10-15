//
//  PlainTextCell.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/24.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class PlainTextCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var contentLabel: UILabel!
    
    var model : MessageModel? {
        didSet {
            refreshCell()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func chatType() {
        backgroundColor = UIColor.background(num: 240)
        nameHeight.constant = 0
    }
    
    func refreshCell() {
        avatarImage.image = UIImage.init(named: (model?.name)!)
        nameLabel.text = model?.name
        contentLabel.text = model?.content
    }

}

