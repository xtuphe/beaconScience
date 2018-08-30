//
//  ChatChoiceCell.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/6/27.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class ChatChoiceCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var button: PMSuperButton!
    
    var model : MessageModel? {
        didSet {
            refreshCell()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        if model?.type == .chosen {
            return
        }
        model?.type = .chosen
        Messages.shared.delegate?.newMessageReceived(model!)
        Messages.shared.saveMessage(message: model!)
        NotificationCenter.default.post(name: notiName(name: "ChoiceViewShouldDismiss"), object: nil)

        if model?.reply != nil {
            var replyModel = MessageModel()
            replyModel.content = model?.reply
            replyModel.type = .normal
            _ = delay(1) {[unowned self] in
                Messages.shared.delegate?.newMessageReceived(replyModel)
                Messages.shared.saveMessage(message: replyModel)
                Messages.shared.messageCheck(currentMessage: self.model!)
            }
        } else {
            Messages.shared.messageCheck(currentMessage: model!)
        }
    }
    
    func refreshCell() {
        button.gradientStartColor = UIColor.randomDark()
        button.gradientEndColor = UIColor.randomDark()
        button.gradientEnabled = true
        button.gradientHorizontal = true

//        button.setTitleColor(UIColor.white, for: .normal)
//        button.setTitle(model?.content, for: .normal)
//
//        button.titleLabel?.numberOfLines = 0
        
        contentLabel.textColor = UIColor.white
        contentLabel.text = model?.content
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
