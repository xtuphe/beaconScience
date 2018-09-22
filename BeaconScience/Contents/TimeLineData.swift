//
//  TimeLineData.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/9/23.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import Foundation

/*
 单例
 初始化加载保存的信息
 从Messages获取新数据
 保存新添加的数据
 tabbar提醒
 TimeLineVC刷新展示
 */

class TimeLine {
    static let shared = TimeLine()
    
    var data : Array<MessageModel> = []
    
    init() {
        //get saved data
        let countKey = Key<Int>("TimeLineCountKey")
        if Defaults.shared.has(countKey) {
            let count = Defaults.shared.get(for: countKey)
            for index in 1...count! {
                data.append(getSavedMessageWith(index: index))
            }
        }
    }
    
    func getSavedMessageWith(index : Int) -> MessageModel {
        let key = Key<SavedMessage>("\(index)")
        //create a userDefaults named beaconScience.TimeLine
        let defaults = Defaults.init(userDefaults: UserDefaults.init(suiteName: "beaconScience.TimeLine")!)
        let savedModel = defaults.get(for: key)!
        var messageModel = MessageModel.init()
        messageModel.content = savedModel.content
        messageModel.type = savedModel.type
        messageModel.name = savedModel.name
        return messageModel
    }

    func newData(message:MessageModel) {
        data.append(message)
        save(message: message)
        //tabbar 红点提醒
    }
    
    func save(message:MessageModel) {
        let key = Key<SavedMessage>("\(data.count)")
        let defaults = Defaults.init(userDefaults: UserDefaults.init(suiteName: "beaconScience.TimeLine")!)
        let saveModel = SavedMessage(content: message.content, type: message.type, name: message.name)
        defaults.set(saveModel, for: key)
    }
}
