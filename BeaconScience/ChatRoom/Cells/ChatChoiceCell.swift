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
    weak var messageCenter : MessageCenter?
    var model : MessageModel? {
        didSet {
            contentLabel.text = model?.content
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapped))
        contentLabel.addGestureRecognizer(tap)
        contentLabel.isUserInteractionEnabled = true
    }
    
    @objc func tapped() {
        if model?.reply != nil {
            let replyModel = MessageModel()
            replyModel.content = model?.reply
            replyModel.type = .normal
            _ = delay(2) {[unowned self] in
                self.messageCenter?.delegate?.newMessageReceived(replyModel)
                self.messageCenter?.saveMessage(message: replyModel)
                self.messageCenter?.whatsNext()
            }
        } else {
            messageCenter?.whatsNext()
        }
        model?.type = .chosen
        messageCenter?.saveMessage(message: model!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
