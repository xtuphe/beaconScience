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
    func presentChoiceView()
}

struct SavedMessage : Codable {
    let content : String
    let type : MessageType
    let name : String
}

class Messages {
    static let shared = Messages()
    
    var data : Array<MessageModel> = []
    var index = 0
    var gap = 2.0
    var name = Conversations.shared.data[0]
    var fileName : String?
    var task : Task?
    var messageBefore : MessageModel?//触发file跳转的message
    weak var delegate : MessagesDelegate?
    let properties : Defaults

    init() {
        printLog(message: "messages init")
        properties = Defaults.init(userDefaults: UserDefaults.init(suiteName: "BeaconScienceProperty")!)
        //检查是否为初次加载
        let firstTimeKey = Key<Bool>("NotFirstTimeKey")
        if Defaults.shared.has(firstTimeKey) {
            reload(name: name)
        } else {
            reload(fileName: "马建国-1")
//            reload(fileName: "Testor-1")
            Defaults.shared.set(true, for: firstTimeKey)
        }
    }
    
    func reload(name: String) {
        
        self.name = name
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
        
        self.fileName = fileName
        index = 0
        data = []
        
        let fileNameArray = (fileName as NSString).components(separatedBy: "-")
        name = fileNameArray.first!
        
        let indexKey = Key<Int>("IndexKey\(fileName)")
        if Defaults.shared.has(indexKey) {
            index = Defaults.shared.get(for: indexKey)!
        }
        
        let fileKey = Key<String>("FileKey\(name)")
        Defaults.shared.set(fileName, for: fileKey)
        
        if messageBefore != nil {
            if messageBefore!.jump != nil {
                self.index = messageBefore!.jump! - 1
            }
            messageBefore = nil
        }
        getData(fileName: fileName)
        whatsNext()
    }
    
    func getData(fileName: String){
        let content = loadContentFile(name: fileName)
        let npcName = fileName.components(separatedBy: "-").first!
        data = transformModel(rawString: content, name: npcName)
    }
    
    func whatsNext(){
        task = delay(gap){ [unowned self] in
            //防越界
            if self.index >= self.data.count {
                return
            }
            //当前行消息
            let currentMessage = self.data[self.index]
            
            //condition check
            if self.conditionCheck(currentMessage: currentMessage) {
                self.whatsNext()
                return
            }
            if currentMessage.action != nil && currentMessage.type != .choice {
                //action check
                self.actionCheck(currentMessage: currentMessage)
            }
            
            //选择 or 朋友圈 or 消息
            if currentMessage.type == .choice {
                //保存选择的index但不保存内容, 所以当切换conversation时会从第一个选择开始加载
                let indexKey = Key<Int>("IndexKey\(self.fileName!)")
                Defaults.shared.set(self.index, for: indexKey)
                self.choicesCheck(message: currentMessage)
            } else if currentMessage.type == .quan
                || currentMessage.type == .quanArticle
                || currentMessage.type == .quanImage {
                TimeLine.shared.newData(message: currentMessage)
                self.messageCheck(currentMessage: currentMessage)
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
        //检查是否需要载入新文件
        if currentMessage.file != nil {
            if index + 1 >= data.count {
                //当前file走完的情况, 存储index, 避免重复消息
                let indexKey = Key<Int>("IndexKey\(self.fileName!)")
                Defaults.shared.set(self.index + 1, for: indexKey)
            }
            messageBefore = currentMessage
            reload(fileName: currentMessage.file!)
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
    
    func conditionCheck(currentMessage: MessageModel) -> Bool {
        //返回true时代表 不符合条件
        if currentMessage.condition != nil {
            //检查是否已有该属性
            let key = Key<Double>((currentMessage.condition?.name)!)
            var savedValue : Double
            let value = Double(currentMessage.condition!.value) ?? 1
            var bool = false
            if self.properties.has(key) {
                savedValue = self.properties.get(for: key)!
                let theOperator = currentMessage.condition?.theOperator
                switch theOperator {
                case ">":
                    bool = savedValue > value
                case "<":
                    bool = savedValue < value
                case ">=":
                    bool = savedValue >= value
                case "<=":
                    bool = savedValue <= value
                case "=":
                    bool = savedValue == value
                default :
                    bool = false
                }
            } else {
                return true
            }
            return !bool
        }
        return false
    }
    
    func actionCheck(currentMessage: MessageModel) {
        let action = currentMessage.action!
        let key = Key<Double>(action.name)
        let value = action.value
        var savedValue : Double
        if self.properties.has(key) {
            savedValue = self.properties.get(for: key)!
        } else {
            savedValue = 0
        }
        switch action.theOperator {
        case "+":
            savedValue += value
        case "-":
            savedValue -= value
        case "*":
            savedValue *= value
        case "/":
            savedValue /= value
        case "=":
            savedValue = value
        default :
            savedValue += 1
        }
        self.properties.set(savedValue, for: key)
    }
    
    func saveMessage(message: MessageModel) {
        
        switch message.type {
        case .others:
            let indexKey = Key<Int>("IndexKey\(fileName!)")
            Defaults.shared.set(index, for: indexKey)
            saveMessageWith(name: message.name, message: message)
        case .choice:
            break
        default:
            let indexKey = Key<Int>("IndexKey\(fileName!)")
            Defaults.shared.set(index, for: indexKey)
            saveMessageWith(name: name, message: message)
        }
        printLog(message: ".....savedIndex\(index)")
    }
    
    func saveMessageWith(name: String, message: MessageModel) {
        let savedCountKey = Key<Int>("\(name)SavedCount")
        var savedCount = 0
        if Defaults.shared.has(savedCountKey) {
            savedCount = Defaults.shared.get(for: savedCountKey)!
        }
        savedCount += 1
        Defaults.shared.set(savedCount, for: savedCountKey)
        
        let defaults = Defaults.init(userDefaults: UserDefaults.init(suiteName: "beaconScience.\(name)")!)
        let messageKey = Key<SavedMessage>("\(savedCount)")
        
        let savedMessage = SavedMessage(content: message.content, type: message.type, name:name)
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
            if !conditionCheck(currentMessage: message) {
                delegate?.newMessageReceived(message)
            }
            index += 1
            if index < data.count {
                let nextMessage = data[index]
                if nextMessage.type == .choice {
                    choicesCheck(message: nextMessage)
                } else {
                    index -= 1
                    delegate?.presentChoiceView()
                }
            } else {
                delegate?.presentChoiceView()
            }
        default:
            break
        }
    }
    
    func choiceSelected(model: MessageModel) {
//        model.type = .chosen
        saveMessage(message: model)
        
        if model.reply != nil {
            var replyModel = MessageModel()
            replyModel.content = model.reply
            replyModel.type = .normal
            _ = delay(1) { [unowned self] in
                self.delegate?.newMessageReceived(replyModel)
                self.saveMessage(message: replyModel)
                self.messageCheck(currentMessage: model)
            }
        } else {
            messageCheck(currentMessage: model)
        }
    }
}
