//
//  StringTransformer.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/15.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

enum ChatActionType{
    case Property
    case Game
}

class ActionModel {
    var type : ChatActionType?
    var gameName : String?
    var mathModel : MathModel?
    
    init(rawStr:String){
        let prefix = rawStr.first
        let content = String(rawStr.dropFirst())
        if prefix == "0" {
            type = ChatActionType.Property
            mathModel = MathModel.init(rawStr: content)
        } else if prefix == "1" {
            type = ChatActionType.Game
            gameName = content
        }
    }
}

class ConditionModel  {
    var name : String?
    var theOperator : String?
    var value : String?
    
    init(rawStr:String){
        let operators = [">=", "<=", ">", "<", "!=", "="]
        for oprtr in operators {
            if rawStr.contains(oprtr) {
                theOperator = oprtr
                var rawArray = (rawStr as NSString).components(separatedBy: oprtr)
                name = rawArray[0]
                value = rawArray[1]
                break
            }
        }
    }
}

class MathModel {
    var name : String?
    var theOperator : String?
    var value : String?
    
    init(rawStr:String){
        let operators = ["+", "-", "*", "/", "%"]
        for oprtr in operators {
            if rawStr.contains(oprtr) {
                theOperator = oprtr
                var rawArray = (rawStr as NSString).components(separatedBy: oprtr)
                name = rawArray[0]
                value = rawArray[1]
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

class MessageModel {
    var index : Int?
    var mark : Int?
    var content : String?
    var choice = false
    var gap : TimeInterval?
    var actions : Array<ActionModel>?
    var conditions : Array<ConditionModel>?
    var date : String?
    var jump : Int?
    
    init(rawStr:String, index: Int) {
        self.index = index
        var targetStr = rawStr
        if rawStr.hasPrefix("* ") {
            choice = true
            targetStr = String(rawStr.dropFirst(2))
        }
        var rawArray = (targetStr as NSString).components(separatedBy: "__")
        content = rawArray[0]
        rawArray.removeFirst()
        for singleLine in rawArray {
            let prefix = singleLine.first
            let surfix = String(singleLine.dropFirst())
            if prefix == "a" {
                let action = ActionModel.init(rawStr: surfix)
                actions?.append(action)
            } else if prefix == "c" {
                let condition = ConditionModel.init(rawStr: surfix)
                conditions?.append(condition)
            } else if prefix == "d" {
                date = surfix
            } else if prefix == "g" {
                gap = (surfix as NSString).doubleValue
            } else if prefix == "j" {
                jump = (surfix as NSString).integerValue
            } else if prefix == "m" {
                mark = (surfix as NSString).integerValue
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
        user = UserDetail.init()
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
                user.name = surfix
            } else if prefix == "event" {
                event = surfix
            } else if prefix == "male" {
                user.male = ["YES", "true", "1", "yes", "TRUE"] .contains(surfix!) ? true : false
            } else if prefix == "job" {
                user.job = surfix
            } else if prefix == "age" {
                user.age = (surfix! as NSString).integerValue
            }
        }
    }
}

func transformModel(rawString:NSString) -> (info :InfoModel, array : [MessageModel]) {
    let rawArray = rawString.components(separatedBy: "\n")
    
    var index = 0
    var resultArray : [MessageModel] = []
    var infoModel : InfoModel?
    for singleLine in rawArray {
        if (singleLine == ""){
            continue//过滤空行
        }
        if index == 0 {
            infoModel = InfoModel.init(rawString: singleLine)
        } else {
            let model = MessageModel.init(rawStr: singleLine, index: index)
            resultArray.append(model)
        }
        index += 1
    }
    return (infoModel!, resultArray)
}

