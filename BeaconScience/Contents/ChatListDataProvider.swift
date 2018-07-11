//
//  ChatListDataProvider.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/6/23.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class ChatListData {
    static let shared = ChatListData()
    
    var data : NSMutableArray
    
    init() {

        data = [InfoModel(name: "Testor1", avatar: "Avatar")]
        
        let fileManager = FileManager.default
        guard let directory =
            fileManager.urls(for: .libraryDirectory,
                             in: .userDomainMask).first
            else { return }
        let url = directory.appendingPathComponent(
            "SavedGames/ChatList")
        
        if fileManager.fileExists(atPath: url.path) {
            data = NSMutableArray.init(array: NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as! NSArray)
            _ = try? fileManager.removeItem(at: url)
        }
    }
    
    func save() {
        
        let fileManager = FileManager.default
        
        guard let directory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        
        let saveURL = directory.appendingPathComponent("SavedGames")
        
        do {
            try fileManager.createDirectory(atPath: saveURL.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            fatalError("Failed to create directory: \(error.debugDescription)")
        }
        
        let fileURL = saveURL.appendingPathComponent("ChatList")
        
        NSKeyedArchiver.archiveRootObject(data, toFile: fileURL.path)
        
    }
        
    //返回新对话之前的位置，如果是0则为全新对话
    func newConversation(name: String, avatar: String) -> Int {
        var newConversation = true
        var index = 0
        for info in data {
            let infoModel = info as! InfoModel
            
            if name == infoModel.name {
                if index == 0 {
                    return -1
                }
                newConversation = false
                data.removeObject(at: index)
                data.insert(infoModel, at: 1)
                break
            }
            index += 1
        }
        if newConversation {
            index = 0 //表示新消息
            let newInfo = InfoModel(name: name, avatar: avatar)
            data.insert(newInfo, at: 1)
        }
        save()
        return index
    }
    
    func selected(index: Int) {
        let model = data[index]
        data.removeObject(at: index)
        data.insert(model, at: 0)
        save()
    }
}
