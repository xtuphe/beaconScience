//
//  ChoiceCardView.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/3.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

let previewHeight : CGFloat = 50
let insetTop : CGFloat = 15

class ChoiceCard : UIView {
    
    var model : MessageModel
    var index = 0
    
    var font = UIFont.systemFont(ofSize: 16)
    var gap : CGFloat = 15
    
    init(model: MessageModel, index : Int) {
        self.model = model
        self.index = index
        super.init(frame:CGRect.init(x: gap, y: insetTop + CGFloat(index) * previewHeight, width: screenWidth() - gap * 2, height: height(string: model.content!, font: font, width: screenWidth() - gap * 4) + 30))
        setupLabel()
        backgroundColor = UIColor.init(red: CGFloat.random(min: 0.3, max: 0.6), green: CGFloat.random(min: 0.3, max: 0.6), blue: CGFloat.random(min: 0.3, max: 0.6), alpha: 1)
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 1
        layer.cornerRadius = gap
        layer.shadowOffset = CGSize.init(width: 2, height: -2)
        clipsToBounds = true
    }
    
    func setupLabel() {
        let label = UILabel.init(frame:CGRect.init(x: gap, y: 0, width: screenWidth() - 4 * gap, height: bounds.size.height))
        label.numberOfLines = 0
        label.text = model.content
        label.font = font
        label.textColor = UIColor.white
        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        self.model = MessageModel()
        super.init(coder: aDecoder)
    }
    
    
    
}

class ChoiceCardView: UIView {
    var data : [MessageModel] = []
    var cards : [ChoiceCard] = []
    var scrollView : UIScrollView?
    
    var baseOffset : CGFloat = 0
    
    func reloadData(){
        var index = 0
        for model in data {
            let card = ChoiceCard.init(model: model, index: index)
            cards.append(card)
            addSubview(card)
            index += 1
        }
        frame = CGRect.init(x: 0, y: 0, width: screenWidth(), height: CGFloat(index) * previewHeight + 2 * insetTop)
        
        
        self.scrollView!.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.scrollView!.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)

    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            let computedOffset = scrollView!.contentOffset.y - baseOffset
            print(computedOffset)
            if computedOffset > 0 && computedOffset < 150{
                let singleOffset = computedOffset / CGFloat(data.count)
                var index = 0
                for card in cards {
                    var frame = card.frame
                    frame.origin.y = insetTop + CGFloat(index) * (singleOffset + previewHeight)
                    index += 1
                    card.frame = frame
                }
            }
            
        } else if keyPath == "contentSize" {
            baseOffset = scrollView!.contentSize.height - scrollView!.bounds.size.height
        }
    }

    
}
