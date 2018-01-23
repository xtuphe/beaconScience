//
//  StringTransformer.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/15.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

public enum ChatMessageTypes {
    case ChatTypeMessage
    case ChatTypeChoice
    case ChatTypeAction
    case ChatTypeCondition
}

//open func typeClassifier(rawString:String) -> NSArray {
//    let rawArray = (rawString as NSString).components(separatedBy: "\n")
//    var index = 0
//    for singleLine in rawArray {
//        if (singleLine == nil || singleLine = ""){
//            continue//过滤空行
//        }
//        
//        index += 1
//    }
//    
//}

/*
 b 标记
 x 选择
 d 动作
 l 类型
 t 条件
 t 跳转
 s 时间
 j 间隔
 
 m mark     标记
 a action   动作
 c condition条件
 j jump     跳转
 d date     显示信息时间
 g gap      与下条间隔时间
 */

open class MessageModel: NSObject {
//    open var index : NSInteger
//    open var content : String
//    open var choices : NSArray
//    open var date : TimeInterval
//    open var actions : NSArray
    
    public init(string:String) {
//        var separatedStrs = "";
        
    }
}


