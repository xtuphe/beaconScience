//
//  StringTransformer.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/15.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

public enum ChatActionType : NSInteger{
    case Property = 0
    case Game
}

open class ActionModel : NSObject {
    open var type : ChatActionType?
    open var gameName : String?
    open var mathModel : MathModel?
    
    public init(rawStr:String){
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

open class ConditionModel : NSObject {
    open var name : String?
    open var theOperator : String?
    open var value : String?
    
    public init(rawStr:String){
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

open class MathModel : NSObject {
    open var name : String?
    open var theOperator : String?
    open var value : String?
    
    public init(rawStr:String){
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

open class MessageModel: NSObject {
    open var index : NSInteger?
    open var mark : NSInteger?
    open var content : String?
    open var choice : Bool?
    open var gap : TimeInterval?
    open var actions : Array<ActionModel>?
    open var conditions : Array<ConditionModel>?
    open var date : String?
    open var jump : NSInteger?
    
    public init(rawStr:String, index: NSInteger) {
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

public func transformModel(rawString:String) -> Array<MessageModel> {
    let rawArray = (rawString as NSString).components(separatedBy: "\n")
    var index = 0
    var resultArray = Array<MessageModel>()
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

