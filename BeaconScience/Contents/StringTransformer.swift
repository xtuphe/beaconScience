//
//  StringTransformer.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/15.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

struct ActionModel {
    var name = "错误计数"
    var theOperator = "+"
    var value = 1.0
    
    init(rawStr:String){
        let operators = ["+", "-", "*", "/", "="]
        for oprtr in operators {
            if rawStr.contains(oprtr) {
                theOperator = oprtr
                var rawArray = (rawStr as NSString).components(separatedBy: oprtr)
                name = rawArray[0]
                value = Double(rawArray[1])!
            }
        }
    }
}

struct ConditionModel  {
    var name : String
    var theOperator : String
    var value : String
    
    init(rawStr:String){
        name = "error"
        theOperator = "+"
        value = "1"
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

/*
 a action   动作
 c condition条件
 m mark     标记
 j jump     跳转
 g gap      与下条间隔时间
 f file     文件
 - reply    只在假选择中，假选择的回复
 i image    图片
 w writings 文章
 n name     名字
 q quan     朋友圈
 t tip      系统提示
 */

enum MessageType : Int, Codable {
    case normal     //普通文本
    case choice     //选择
    case chosen     //已发送
    case others     //其他人
    case article    //文章
    case image      //图片
    case quanImage  //朋友圈图片
    case quanArticle//朋友圈文章
    case quan       //朋友圈文本
}

struct MessageModel {
    var index : Int
    var content : String!
    var name : String!
    var type = MessageType.normal
    var gap : TimeInterval?
    var action : ActionModel?
    var condition : ConditionModel?
    var jump : String?
    var mark : String?
    var file : String?
    var reply : String?
    var money : Double?
    var tip : String?
    
    init(rawStr:String, index: Int, name:String) {
        self.index = index
        self.name = name
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
                action = ActionModel.init(rawStr: surfix)
            } else if prefix == "c" {
                condition = ConditionModel.init(rawStr: surfix)
            } else if prefix == "g" {
                gap = Double(surfix)
            } else if prefix == "j" {
                jump = surfix
            } else if prefix == "f" {
                file = surfix
            } else if prefix == "-" {
                reply = surfix
            } else if prefix == "n" {
                self.name = surfix
                if type == .normal {
                    //因为朋友圈也需要人名信息，只有在不是其他情况的情况下将其认为是其他人的信息
                    type = .others
                }
            } else if prefix == "i" {
                if surfix == "q" {
                    type = .quanImage
                    gap = 0.1
                } else if surfix == "c" {
                    type = .image
                }
            } else if prefix == "w" {
                if surfix == "q" {
                    type = .quanArticle
                    gap = 0.1
                } else {
                    type = .article
                }
            } else if prefix == "q" {
                type = .quan
                gap = 0.1
            } else if prefix == "r" {
                money = Double(surfix)
            } else if prefix == "m" {
                mark = surfix
            } else if prefix == "t" {
                tip = surfix
            }
        }
    }
    
    init() {
        index = 0
    }
    
}

func transformModel(rawString:NSString, name:String) -> ([MessageModel], [MessageModel]) {
    let rawArray = rawString.components(separatedBy: "\n")
    var index = 0
    var resultArray : [MessageModel] = []
    var markedArray : [MessageModel] = []
    for singleLine in rawArray {
        if (singleLine == ""){
            continue//过滤空行
        }
        let model = MessageModel.init(rawStr: singleLine, index: index, name:name)
        if model.mark != nil {
            markedArray.append(model)
        }
        resultArray.append(model)
        index += 1
    }
    return (resultArray, markedArray)
}

func loadContentFile(name:String) -> NSString {
    let filePath = Bundle.main.path(forResource: name, ofType: "txt")
    let fileUrl = URL(fileURLWithPath: filePath!)
    let fileContent = NSData.init(contentsOf: fileUrl)
    return NSString(data: fileContent! as Data, encoding: String.Encoding.utf8.rawValue)!
}

