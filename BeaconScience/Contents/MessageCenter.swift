//
//  MessageCenter.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/2/5.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

protocol MessageCenterDelegate: AnyObject {
    func newMessageReceived(_ message: MessageModel)
    func newConversation(_ infoModel: InfoModel)
}

struct SavedMessage : Codable {
    let content : String
    let type : MessageType
}

class MessageCenter {
    static let shared = MessageCenter(infoModel: ChatListData.shared.data[0] as! InfoModel)
    
    var contentArray : Array<MessageModel> = []
    var index = 0
    var gap = 2.0
    var task : Task?
    var fileName = "Test1"
    var infoModel : InfoModel? {
        didSet{
            if oldValue != nil && oldValue?.name != infoModel?.name {
                self.delegate?.newConversation(infoModel!)
            }
        }
    }

    weak var delegate : MessageCenterDelegate?
    
    init(infoModel: InfoModel) {
        refresh(infoModel: infoModel)
    }
    
    func refresh(infoModel: InfoModel) {
        let fileKey = Key<String>("FileKey\(infoModel.name)")
        let indexKey = Key<Int>("IndexKey\(infoModel.name)")
        let unreadKey = Key<Int>("UnreadKey\(infoModel.name)")
        
        if Defaults.shared.has(unreadKey) {
            let unreadCount = Defaults.shared.get(for: unreadKey)
            if unreadCount == 0 {
                return
            }
        }
        
        if Defaults.shared.has(fileKey) {
            fileName = Defaults.shared.get(for: fileKey)!
        }
        
        getContents(fileName: fileName)
        
        if Defaults.shared.has(indexKey) {
            index = Defaults.shared.get(for: indexKey)!
        } else {
            index = 0
        }
    }
    
    func whatsNext(){
        task = delay(gap){ [unowned self] in
            //防越界
            guard self.index < self.contentArray.count else { return }
            //当前行消息
            let currentMessage = self.contentArray[self.index]
            //是否为选择
            if currentMessage.type == .choice {
                self.choicesCheck(message: currentMessage)
            } else {
                //展示当前消息
                self.delegate?.newMessageReceived(currentMessage)
                //本地化当前消息
                self.saveMessage(message: currentMessage)
                self.messageCheck(currentMessage: currentMessage)
            }
        }
    }
    
    func messageCheck(currentMessage: MessageModel) {
        
        //检查是否需要更新朋友圈
        if currentMessage.quan != nil {
            //通知发送朋友圈
            
        }
        //检查是否需要载入新文件
        if currentMessage.file != nil {
            newFile(fileName: currentMessage.file!)
        }
        //检查是否需要跳转
        if currentMessage.jump != nil {
            self.index = currentMessage.jump! - 2
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
        case .others, .choice, .invalid:
            break
        case .chosen://只保存选中的
            fallthrough
        default:
            let indexKey = Key<Int>("IndexKey\(infoModel!.name)")
            Defaults.shared.set(index, for: indexKey)
            
            let savedCountKey = Key<Int>("\(infoModel!.name)SavedIndex")
            var savedIndex = 0
            if Defaults.shared.has(savedCountKey) {
                savedIndex = Defaults.shared.get(for: savedCountKey)!
            }
            savedIndex += 1
            Defaults.shared.set(savedIndex, for: savedCountKey)
            
            let defaults = Defaults.init(userDefaults: UserDefaults.init(suiteName: "beaconScience.\(infoModel!.name)")!)
            let messageKey = Key<SavedMessage>("\(savedIndex)")
            let savedMessage = SavedMessage(content: message.content!, type: message.type)
            Defaults.shared.set(savedMessage, for: messageKey)
            defaults.set(savedMessage, for: messageKey)

        }
        
    }
    
    func newFile(fileName: String) {
        let content = loadContentFile(name: fileName)
        let (info, contents) = transformModel(rawString: content)
        if info.name != infoModel?.name {
            infoModel = info
        }
        contentArray = contents
        let fileKey = Key<String>("FileKey\(infoModel!.name)")
        Defaults.shared.set(fileName, for: fileKey)
        index = 0
        let indexKey = Key<Int>("IndexKey\(infoModel!.name)")
        Defaults.shared.set(index, for: indexKey)
    }
    
    func choicesCheck(message: MessageModel) {
        switch message.type {
        case .choice:
            if task != nil {
                cancel(task)
                task = nil
            }
            delegate?.newMessageReceived(message)
            index += 1
            if index < contentArray.count {
                let nextMessage = contentArray[index]
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
    
    func getContents(fileName: String){
        let content = loadContentFile(name: fileName)
        let (info, contents) = transformModel(rawString: content)
        infoModel = info
        contentArray = contents
    }
    
    func setupNotification(){
        NotificationCenter.default.addObserver(forName: notiName(name: "testNoti"), object: nil, queue: nil) { (theNoti) in
            print("lolo", theNoti)
        }
    }
    
    func save(targetArray:Array<Any>){
        
    }
    


    func notiReceived(noti: NSNotification) {
        print("haha", noti.name)
    }
    
}


