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
    
    var contentArray : Array<MessageModel> = [] {
        didSet {
            printLog(message: ".....messageCenterCount\(contentArray.count)")
        }
    }
    var index = 0 {
        didSet{
            printLog(message: ".....index : \(index)")
        }
    }
    var gap = 2.0
    var task : Task?
    var fileName : String?
    var infoModel : InfoModel? {
        didSet{
            if oldValue != nil && oldValue?.name != infoModel?.name {
                
                self.delegate?.newConversation(infoModel!)
                printLog(message: ".....current name before refresh\(infoModel!.name)")
                refresh(infoModel: infoModel!)
                printLog(message: ".....current name\(infoModel!.name)")
            }
        }
    }

    weak var delegate : MessageCenterDelegate?
    
    init(infoModel: InfoModel) {
        if fileName == nil {
            fileName = "Test1"
        }
        refresh(infoModel: infoModel)
    }
    
    func refresh(infoModel: InfoModel) {
        let fileKey = Key<String>("FileKey\(infoModel.name)")
//        let unreadKey = Key<Int>("UnreadKey\(infoModel.name)")
        
//        if Defaults.shared.has(unreadKey) {
//            let unreadCount = Defaults.shared.get(for: unreadKey)
//        }
        
        if Defaults.shared.has(fileKey) {
            fileName = Defaults.shared.get(for: fileKey)!
        }
        
        if fileName == nil {
            return
        }
        getContents(fileName: fileName!)

        let indexKey = Key<Int>("IndexKey\(fileName!)")
        
        if Defaults.shared.has(indexKey) {
            index = Defaults.shared.get(for: indexKey)!
        } else {
            index = 0
        }
        
        whatsNext()
    }
    
    func whatsNext(){
        task = delay(gap){ [unowned self] in
            //防越界
            guard self.index < self.contentArray.count else { return }
            //当前行消息
            let currentMessage = self.contentArray[self.index]
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
        case .others:
            let indexKey = Key<Int>("IndexKey\(infoModel!.name)")
            Defaults.shared.set(index, for: indexKey)
            saveMessageWith(name: message.name!, message: message)
        case .choice, .invalid:
            break
        case .chosen://只保存选中的
            fallthrough
        default:
            let indexKey = Key<Int>("IndexKey\(infoModel!.name)")
            Defaults.shared.set(index, for: indexKey)
            saveMessageWith(name: infoModel!.name, message: message)
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
    
    func newConversationSelected(infoModel: InfoModel) {
        if fileName != nil {
            let fileKey = Key<String>("FileKey\(infoModel.name)")
            Defaults.shared.set(fileName!, for: fileKey)
            let indexKey = Key<Int>("IndexKey\(fileName!)")
            Defaults.shared.set(index, for: indexKey)
            fileName = nil
        }
        index = 0
        contentArray = []
        self.infoModel = infoModel
    }
    
    func newFile(fileName: String) {
        self.fileName = fileName
        let content = loadContentFile(name: fileName)
        let (info, contents) = transformModel(rawString: content)
        if info.name != infoModel?.name {
            infoModel = info
        }
        contentArray = contents
        let fileKey = Key<String>("FileKey\(infoModel!.name)")
        Defaults.shared.set(fileName, for: fileKey)
        index = 0
        let indexKey = Key<Int>("IndexKey\(fileName)")
        Defaults.shared.set(index, for: indexKey)
        index -= 1 //因为接下来检查index会+1或跳转，所以此处需要-1
    }
    
    func choicesCheck(message: MessageModel) {
        if self.infoModel?.name != ChatListData.shared.onSightName {
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
        if infoModel?.avatar != info.avatar {
            //首次露面
            infoModel = info
        }
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


