//
//  ArticleCell.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/24.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var articleBackgroundView: UIView!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    
    var model : MessageModel? {
        didSet {
            refreshCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(ArticleCell.tapped))
        articleBackgroundView.addGestureRecognizer(tap)
    }

    func chatType() {
        titleHeight.constant = 0
        backgroundColor = UIColor.background(num: 240)
        articleBackgroundView.backgroundColor = UIColor.white
    }
    
    func refreshCell() {
        avatarImageView.image = UIImage.init(named: (model?.name)!)
        nameLabel.text = model?.name
        titleLabel.text = model?.content
    }
    
    @objc func tapped() {
        let articleVC = ArticleDetailVC()
        articleVC.fileName = model?.content
        Router.show(controller: articleVC)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
