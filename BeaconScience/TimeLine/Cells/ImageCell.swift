//
//  ImageCell.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/24.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class ImageCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    
    var model : MessageModel? {
        didSet {
            refreshCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        imageSetup()
    }

    func imageSetup() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(ImageCell.imageTapped))
        contentImage.addGestureRecognizer(tap)
        contentImage.isUserInteractionEnabled = true
    }
    
    @objc func imageTapped() {
        var images = [SKPhoto]()
        let photo = SKPhoto.photoWithImage(UIImage.init(named: model!.image!)!)
        images.append(photo)
        let browser = SKPhotoBrowser(originImage: contentImage.image ?? UIImage(), photos: images, animatedFromView: contentImage)
        browser.initializePageIndex(0)
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayStatusbar = true
        Router.rootVC().present(browser, animated: true, completion: {})
    }
    
    func chatType() {
        backgroundColor = UIColor.background(num: 240)
        nameHeight.constant = 0
    }
    
    func refreshCell() {
        contentImage.image = UIImage.init(named: (model?.image!)!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
