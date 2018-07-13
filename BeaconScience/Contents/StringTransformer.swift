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
    case News
    case PayCheck //获得报酬
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
 a action   动作
 c condition条件
 j jump     跳转
 g gap      与下条间隔时间
 f file     文件
 - reply    只在假选择中，假选择的回复
 q quan     朋友圈
 n name     名字, 如果有名字，说明不是当前聊天对象
 */

enum MessageType : Int, Codable {
    case normal
    case choice
    case chosen
    case invalid
    case others
}

struct MessageModel {
    var index : Int
    var content : String?
    var gap : TimeInterval?
    var actions : Array<ActionModel>?
    var conditions : Array<ConditionModel>?
    var jump : Int?
    var file : String?
    var reply : String?
    var quan : String?
    var name : String?
    var type = MessageType.normal
    
    init(rawStr:String, index: Int) {
        self.index = index
        var targetStr = rawStr
        if rawStr.hasPrefix("* ") {
            type = .choice
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
            } else if prefix == "g" {
                gap = (surfix as NSString).doubleValue
            } else if prefix == "j" {
                jump = (surfix as NSString).integerValue
            } else if prefix == "f" {
                file = surfix
            } else if prefix == "-" {
                reply = surfix
            } else if prefix == "q" {
                quan = surfix
            } else if prefix == "n" {
                name = surfix
                type = .others
            }
        }
    }
    
    init() {
        index = 0
    }
    
}

func transformModel(rawString:NSString) -> [MessageModel] {
    let rawArray = rawString.components(separatedBy: "\n")
    var index = 0
    var resultArray : [MessageModel] = []
    for singleLine in rawArray {
        if (singleLine == ""){
            continue//过滤空行
        }
        let model = MessageModel.init(rawStr: singleLine, index: index)
        resultArray.append(model)
        index += 1
    }
    return resultArray
}

func loadContentFile(name:String) -> NSString {
    let filePath = Bundle.main.path(forResource: name, ofType: "txt")
    let fileUrl = URL(fileURLWithPath: filePath!)
    let fileContent = NSData.init(contentsOf: fileUrl)
    return NSString(data: fileContent! as Data, encoding: String.Encoding.utf8.rawValue)!
}

