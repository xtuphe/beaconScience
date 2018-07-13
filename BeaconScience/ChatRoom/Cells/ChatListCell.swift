//
//  ChatListCell.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/7/10.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class ChatListCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    var name : String? {
        didSet{
            imageView.image = UIImage.init(named: name!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    
    
}
