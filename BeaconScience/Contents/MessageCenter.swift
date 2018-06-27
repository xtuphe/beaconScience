//
//  MessageCenter.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/2/5.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

protocol NewMessageDelegate: AnyObject {
    func newMessageReceived(_ message: MessageModel)
}

class MessageCenter {
    var timer = Timer()
    var contentArray : Array<MessageModel> = []
    var index = 0
    var savedCount = 0
    var secondsLeft = 0
    var infoModel : InfoModel?
    
    init() {
        getContents(fileName: "Empty")
        setupTimer()
    }
    
    weak var delegate : NewMessageDelegate?
    
    func setupTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[unowned self](timer) in
            if self.index < self.contentArray.count {
                let currentMessage = self.contentArray[self.index]
                self.delegate?.newMessageReceived(currentMessage)
                self.index += 1
                self.choicesCheck()
            }
            //TODO: check next file
        })
    }
    
    func decisionMade() {
        setupTimer()
        timer.fire()
    }
    
    func choicesCheck() {
        guard index < contentArray.count else { return }
        let currentMessage = contentArray[index]
        if currentMessage.choice {
            self.delegate?.newMessageReceived(currentMessage)
            index += 1
            choicesCheck()
            timer.invalidate()
        }
    }
    
    func getContents(fileName: String){
        let content = loadContentFile(name: fileName)
        let (info, contents) = transformModel(rawString: content)
        infoModel = info
        contentArray = contents
        //        checkSaves()
    }
    
    func setupNotification(){
        NotificationCenter.default.addObserver(forName: notiName(name: "testNoti"), object: nil, queue: nil) { (theNoti) in
            print("lolo", theNoti)
        }
    }
    
    func save(targetArray:Array<Any>){
        
    }
    
    /*
    
    func checkSaves(){
        let countStr = String.init(format: "saveCount", self.infoModel.name!)
        let keyOfCount = Key<Int>(countStr)
        if Defaults.shared.has(keyOfCount) {
            self.savedCount = Defaults.shared.get(for: keyOfCount)!
        }
        if self.savedCount > 0 {
            loadHistory()
        } else {
            
        }
    }
    
    func loadHistory(){
        for i in 1...self.savedCount {
            let messageStr = String.init(format: self.infoModel.name!, i)
            let keyOfMessage = Key<String>(messageStr)
            self.dataArray.append(Defaults.shared.get(for: keyOfMessage)!)
        }
    }
    
    func save(content: String){
        self.savedCount += 1
        let countStr = String.init(format: "saveCount", self.infoModel.name!)
        let keyOfCount = Key<Int>(countStr)
        Defaults.shared.set(self.savedCount, for: keyOfCount)
        let messageStr = String.init(format: self.infoModel.name!, self.savedCount)
        let keyOfMessage = Key<String>(messageStr)
        Defaults.shared.set(content, for: keyOfMessage)
    }

 
 */
    func checkIfHasNewMessage() -> Bool {
        if secondsLeft > 0 {
            secondsLeft -= 1
            return false
        }
        return true
    }
    
    func notiReceived(noti: NSNotification) {
        print("haha", noti.name)
    }
    
}


