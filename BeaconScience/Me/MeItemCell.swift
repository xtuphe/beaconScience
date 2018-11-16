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
            showResetAlert()
        }
        if text == "文件" {
            Router.presentFilesVC()
        }
        if text == "关于" {
            Router.presentMD(fileName:"关于")
        }
        if text == "Bonus$" {
            Router.presentBonus(amount: 9999)
        }
        if text == "Advertisement" {
            GoogleAds.shared.presentInterstitial()
        }
    }
    
    func showResetAlert() {
        let alert = UIAlertController.init()
        let resetAction = UIAlertAction.init(title: "重置", style: .destructive) { (action) in
            Defaults.reset()
            Conversations.shared.delete()
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            
        }
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        Router.show(controller: alert)
    }
    
}
