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
    var model : MessageModel? {
        didSet {
            refreshCell()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapped))
        contentLabel.addGestureRecognizer(tap)
        contentLabel.isUserInteractionEnabled = true
    }
    
    func refreshCell() {
        switch model!.type {
        case MessageType.chosen:
            contentLabel.textColor = UIColor.black
        default:
            contentLabel.textColor = UIColor.blue
        }
        contentLabel.text = model?.content
    }
    
    @objc func tapped() {
        if model?.type == .chosen {
            return
        }
        model?.type = .chosen
        Messages.shared.saveMessage(message: model!)

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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
