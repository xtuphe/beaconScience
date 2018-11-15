//
//  MeAvatarCell.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/29.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class MeAvatarCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(MeAvatarCell.showAlert))
        addGestureRecognizer(tap)
    }
    
    @objc func showAlert() {
        let alert = UIAlertController.init()
        let changeAvatar = UIAlertAction.init(title: "更改头像", style: .destructive) { (action) in
            
        }
        let changeName = UIAlertAction.init(title: "更改头像", style: .destructive) { (action) in
            
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            
        }
        alert.addAction(changeAvatar)
        alert.addAction(changeName)
        alert.addAction(cancelAction)
        Router.show(controller: alert)
    }


}
