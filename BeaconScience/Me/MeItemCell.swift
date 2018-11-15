//
//  MeItemCell.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/29.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class MeItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(MeItemCell.tapped))
        addGestureRecognizer(tap)
    }

    @objc func tapped() {
        let text = itemLabel.text
        if text == "重置" {
            Defaults.reset()
            Conversations.shared.delete()
        }
        if text == "文件" {
            Router.presentFilesVC()
        }
        if text == "Bonus$" {
            Router.presentBonus(amount: 9999)
        }
        if text == "Advertisement" {
            GoogleAds.shared.presentInterstitial()
        }
    }
    
}
