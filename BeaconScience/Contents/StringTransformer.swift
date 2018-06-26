//
//  StringTransformer.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/15.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

enum ChatActionType : NSInteger{
    case Property = 0
    case Game
}

class ActionModel : NSObject {
    var type : ChatActionType?
    var gameName : String?
    var mathModel : MathModel?
    
    init(rawStr:String){
        let prefix = rawStr.first
        let content = String(rawStr.dropFirst())
        if prefix == "0" {
            self.type = ChatActionType.Property
            self.mathModel = MathModel.init(rawStr: content)
        } else if prefix == "1" {
            self.type = ChatActionType.Game
            self.gameName = content
        }
    }
}

class ConditionModel : NSObject {
    var name : String?
    var theOperator : String?
    var value : String?
    
    init(rawStr:String){
        let operators = [">=", "<=", ">", "<", "!=", "="]
        for oprtr in operators {
            if rawStr.contains(oprtr) {
                self.theOperator = oprtr
                var rawArray = (rawStr as NSString).components(separatedBy: oprtr)
                self.name = rawArray[0]
                self.value = rawArray[1]
                break
            }
        }
    }
}

class MathModel : NSObject {
    var name : String?
    var theOperator : String?
    var value : String?
    
    init(rawStr:String){
        let operators = ["+", "-", "*", "/", "%"]
        for oprtr in operators {
            if rawStr.contains(oprtr) {
                self.theOperator = oprtr
                var rawArray = (rawStr as NSString).components(separatedBy: oprtr)
                self.name = rawArray[0]
                self.value = rawArray[1]
            }
        }
    }
}

/*
 m mark     标记
 a action   动作
 c condition条件
 j jump     跳转
 d date     显示信息时间
 g gap      与下条间隔时间
 */

class MessageModel: NSObject {
    var index : NSInteger?
    var mark : NSInteger?
    var content : String?
    var choice : Bool?
    var gap : TimeInterval?
    var actions : Array<ActionModel>?
    var conditions : Array<ConditionModel>?
    var date : String?
    var jump : NSInteger?
    
    init(rawStr:String, index: NSInteger) {
        self.index = index
        var targetStr = rawStr
        if rawStr.hasPrefix("* ") {
            self.choice = true
            targetStr = String(rawStr.dropFirst(2))
        }
        var rawArray = (targetStr as NSString).components(separatedBy: "__")
        self.content = rawArray[0]
        rawArray.removeFirst()
        for singleLine in rawArray {
            let prefix = singleLine.first
            let surfix = String(singleLine.dropFirst())
            if prefix == "a" {
                let action = ActionModel.init(rawStr: surfix)
                self.actions?.append(action)
            } else if prefix == "c" {
                let condition = ConditionModel.init(rawStr: surfix)
                self.conditions?.append(condition)
            } else if prefix == "d" {
                self.date = surfix
            } else if prefix == "g" {
                self.gap = (surfix as NSString).doubleValue
            } else if prefix == "j" {
                self.jump = (surfix as NSString).integerValue
            } else if prefix == "m" {
                self.mark = (surfix as NSString).integerValue
            }
        }
    }
}

struct UserDetail {
    var name : String?
    var male : Bool?
    var age : Int?
    var job : String?
    var avatar : String?
}

struct InfoModel {
    var user : UserDetail
    var event : String?

    init(rawString:String) {
        self.user = UserDetail.init()
        let rawArray = rawString.components(separatedBy: "\n")
        for singleLine in rawArray {
            if (singleLine == ""){
                continue//过滤空行
            }
            let convertedStr = rawString.replacingOccurrences(of: "：", with: ":")
            let singleLineArray = convertedStr.components(separatedBy: ":")
            let prefix = singleLineArray.first
            let surfix = singleLineArray.last
            if prefix == "name" {
                self.user.name = surfix
            } else if prefix == "event" {
                self.event = surfix
            } else if prefix == "male" {
                self.user.male = ["YES", "true", "1", "yes", "TRUE"] .contains(surfix!) ? true : false
            } else if prefix == "job" {
                self.user.job = surfix
            } else if prefix == "age" {
                self.user.age = (surfix! as NSString).integerValue
            }
        }
    }
}

func transformModel(rawString:NSString) -> Array<Any> {
    let rawArray = rawString.components(separatedBy: "\n")
    
    var index = 0
    var resultArray = Array<Any>()
    for singleLine in rawArray {
        if (singleLine == ""){
            continue//过滤空行
        }
        if index == 0 {
            let model = InfoModel.init(rawString: singleLine)
            resultArray.append(model)
        } else {
            let model = MessageModel.init(rawStr: singleLine, index: index)
            resultArray.append(model)
        }
        index += 1
    }
    return resultArray
}

