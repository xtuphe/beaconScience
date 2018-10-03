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

enum ChoiceCardState {
    case normal
    case pending
    case selected
    case bottom
}

enum CardsViewState {
    case normal
    case pending
}

class ChoiceCard : UIView {
    
    var model : MessageModel
    var index = 0
    
    var font = UIFont.systemFont(ofSize: 16)
    var gap : CGFloat = 15
    
    var originalFrame : CGRect
    var state : ChoiceCardState = .normal {
        didSet {
            if oldValue != state {
                stateChanged()
            }
        }
    }
    
    unowned var cardsView : ChoiceCardView
    
    init(model: MessageModel, index : Int, cardsView : ChoiceCardView) {
        self.model = model
        self.index = index
        self.cardsView = cardsView
        self.originalFrame = CGRect.init(x: gap, y: insetTop + CGFloat(index) * previewHeight, width: screenWidth() - gap * 2, height: strHeight(string: model.content!, font: font, width: screenWidth() - gap * 4) + 30)
        super.init(frame:originalFrame)
        setupLabel()
        backgroundColor = UIColor.init(red: CGFloat.random(min: 0.3, max: 0.6), green: CGFloat.random(min: 0.3, max: 0.6), blue: CGFloat.random(min: 0.3, max: 0.6), alpha: 1)
        layer.cornerRadius = gap
        layer.masksToBounds = true
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(ChoiceCard.tapped))
        addGestureRecognizer(tapGesture)
    }
    
    func choiceSelected() {
        model.type = .chosen
        Messages.shared.choiceSelected(model: model)
    }
    
    @objc func tapped() {
        if state == .normal {
            state = .pending
            for card in cardsView.cards {
                cardsView.state = .pending
                if card.state == .normal {
                    card.state = .bottom
                }
            }
        } else if state == .bottom {
            cardsView.state = .normal
            for card in cardsView.cards {
                card.state = .normal
            }
        } else if state == .pending {
            state = .selected
            choiceSelected()
            NotificationCenter.default.post(name: notiName(name: "ChoiceViewShouldDismiss"), object: nil)
        }
        
    }
    
    func stateChanged() {
        switch state {
        case .pending:
            printLog(message: "dismiss")
        case .selected:
            printLog(message: "dismiss")
        case .bottom:
            printLog(message: "dismiss")
        default:
            printLog(message: "dismiss")
        }
        animatePosition()
    }
    
    func animatePosition() {
        switch state {
        case .pending:
            var topFrame = originalFrame
            topFrame.origin.y = gap
            UIView.animate(withDuration: 0.2) {
                self.frame = topFrame
            }
        case .selected:
            printLog(message: "selected")
            
        case .bottom:
            let reversedIndex : CGFloat = CGFloat(cardsView.cards.count - 1 - index)
            let bottomFrame = CGRect.init(x: gap + reversedIndex * 2, y: cardsView.frame.size.height - 20 - reversedIndex * 10, width: screenWidth() - 2 * gap - 2 * reversedIndex * 2, height: frame.size.height)
            UIView.animate(withDuration: 0.2) {
                self.frame = bottomFrame
            }
        default:
            UIView.animate(withDuration: 0.2) {
                self.frame = self.originalFrame
            }
        }
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
        self.originalFrame = CGRect.zero
        self.cardsView = ChoiceCardView().copy() as! ChoiceCardView
        super.init(coder: aDecoder)
    }
    
    
    
}

class ChoiceCardView: UIView {
    var data : [MessageModel] = []
    var cards : [ChoiceCard] = []
    var scrollView : UIScrollView?
    
    var baseOffset : CGFloat = 0
    var state : CardsViewState = .normal
    
    func reloadData(){
        var index = 0
        for model in data {
            let card = ChoiceCard.init(model: model, index: index, cardsView: self)
            cards.append(card)
            addSubview(card)
            index += 1
        }
        frame = CGRect.init(x: 0, y: 0, width: screenWidth(), height: CGFloat(index) * previewHeight + 2 * insetTop)
        
        
        self.scrollView!.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.scrollView!.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)

    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if state != .normal {
            return
        }
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
