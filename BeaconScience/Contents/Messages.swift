//
//  Messages.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/7/13.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import Foundation

protocol MessagesDelegate: AnyObject {
    func newMessageReceived(_ message: MessageModel)
}

struct SavedMessage : Codable {
    let content : String
    let type : MessageType
}

class Messages {
    static let shared = Messages()
    
    var data : Array<MessageModel> = []
    var index = 0
    var gap = 2.0
    var name = Conversations.shared.data[0] as! String
    var fileName : String?
    var task : Task?
    var messageBefore : MessageModel?//触发file跳转的message
    weak var delegate : MessagesDelegate?

    init() {
        
    }
    
    func reload(name: String) {
        
        fileName = nil
        index = 0
        data = []
        
        let fileKey = Key<String>("FileKey\(name)")
        if Defaults.shared.has(fileKey) {
            fileName = Defaults.shared.get(for: fileKey)!
            getData(fileName: fileName!)
            let indexKey = Key<Int>("IndexKey\(fileName!)")
            if Defaults.shared.has(indexKey) {
                index = Defaults.shared.get(for: indexKey)!
            }
            whatsNext()
        }
    }
    
    func reload(fileName: String) {
        index = 0
        data = []
        
        let fileNameArray = (fileName as NSString).components(separatedBy: "-")
        name = fileNameArray.first!
        
        if Conversations.shared.newConversation(name: name) != 0 {
            let indexKey = Key<Int>("IndexKey\(fileName)")
            if Defaults.shared.has(indexKey) {
                index = Defaults.shared.get(for: indexKey)!
            }
        }
        
        let fileKey = Key<String>("FileKey\(name)")
        Defaults.shared.set(fileName, for: fileKey)
        
        if messageBefore != nil {
            if messageBefore!.jump != nil {
                self.index = messageBefore!.jump! - 1
            }
        }
        whatsNext()
    }
    
    func getData(fileName: String){
        let content = loadContentFile(name: fileName)
        data = transformModel(rawString: content)
    }
    
    func whatsNext(){
        task = delay(gap){ [unowned self] in
            //防越界
            guard self.index < self.data.count else { return }
            //当前行消息
            let currentMessage = self.data[self.index]
            //是否为选择
            if currentMessage.type == .choice{
                self.choicesCheck(message: currentMessage)
            } else {
                //展示当前消息
                self.delegate?.newMessageReceived(currentMessage)
                //本地化当前消息
                self.saveMessage(message: currentMessage)
                self.messageCheck(currentMessage: currentMessage)
            }
            printLog(message: ".....currentIndex\(self.index)")
        }
    }
    
    func messageCheck(currentMessage: MessageModel) {
        
        //检查是否需要更新朋友圈
        if currentMessage.quan != nil {
            //通知发送朋友圈
            
        }
        //检查是否需要载入新文件
        if currentMessage.file != nil {
            reload(fileName: currentMessage.file!)
            messageBefore = currentMessage
            return
        }
        //检查是否需要跳转
        if currentMessage.jump != nil {
            self.index = currentMessage.jump! - 1
        } else {
            self.index += 1
        }
        //检查下条消息间隔时间
        if currentMessage.gap != nil {
            if currentMessage.gap! > 10 {
                //超过10秒，注册通知
                
            } else {
                self.gap = currentMessage.gap!
                self.whatsNext()
            }
        } else {
            self.gap = 0.5
            self.whatsNext()
        }
        
    }
    
    func saveMessage(message: MessageModel) {
        
        switch message.type {
        case .others:
            let indexKey = Key<Int>("IndexKey\(name)")
            Defaults.shared.set(index, for: indexKey)
            saveMessageWith(name: message.name!, message: message)
        case .choice:
            break
        default:
            let indexKey = Key<Int>("IndexKey\(name)")
            Defaults.shared.set(index, for: indexKey)
            saveMessageWith(name: name, message: message)
        }
        printLog(message: ".....savedIndex\(index)")
    }
    
    func saveMessageWith(name: String, message: MessageModel) {
        let savedCountKey = Key<Int>("\(name)SavedIndex")
        var savedIndex = 0
        if Defaults.shared.has(savedCountKey) {
            savedIndex = Defaults.shared.get(for: savedCountKey)!
        }
        savedIndex += 1
        Defaults.shared.set(savedIndex, for: savedCountKey)
        
        let defaults = Defaults.init(userDefaults: UserDefaults.init(suiteName: "beaconScience.\(name)")!)
        let messageKey = Key<SavedMessage>("\(savedIndex)")
        let savedMessage = SavedMessage(content: message.content!, type: message.type)
        Defaults.shared.set(savedMessage, for: messageKey)
        defaults.set(savedMessage, for: messageKey)
    }

    func choicesCheck(message: MessageModel) {
        if name != Conversations.shared.onSightName {
            if task != nil {
                cancel(task)
                task = nil
                index -= 1
            }
            return
        }
        switch message.type {
        case .choice:
            if task != nil {
                cancel(task)
                task = nil
            }
            delegate?.newMessageReceived(message)
            index += 1
            if index < data.count {
                let nextMessage = data[index]
                if nextMessage.type == .choice {
                    choicesCheck(message: nextMessage)
                } else {
                    index -= 1
                }
            }
        default:
            break
        }
    }
}
