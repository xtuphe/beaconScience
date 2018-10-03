//
//  Conversations.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/7/13.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import Foundation

class Conversations {
    static let shared = Conversations()
    var data : Array<String> = []
    var onSightName: String?
    
    init() {
        
        let fileManager = FileManager.default
        guard let directory =
            fileManager.urls(for: .libraryDirectory,
                             in: .userDomainMask).first
            else { return }
        let url = directory.appendingPathComponent(
            "SavedGames/Conversations")
        
        if fileManager.fileExists(atPath: url.path) {
            data = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as! Array<String>
            _ = try? fileManager.removeItem(at: url)
        } else {
            data = ["马建国"]
        }
        
        /*
        for name in data {
            if name as! String == "Ad man" {
                //preload ad
                _ = GoogleAds.shared
                break
            }
        }
        */
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
        
        let fileURL = saveURL.appendingPathComponent("Conversations")
        
        NSKeyedArchiver.archiveRootObject(data, toFile: fileURL.path)
        for obj in data {
            let name = obj
            printLog(message: ".....list data saved\(name)")
        }
    }
    
    //返回新对话之前的位置，如果是0则为全新对话
    func newConversation(name: String) -> Int {
        if name == data[0] {
            return -1
        }
        var newConversation = true
        var index = 0
        for obj in data {
            let object = obj
            
            if name == object {
                newConversation = false
                data.remove(at: index)
                data.insert(object, at: 1)
                break
            }
            index += 1
        }
        if newConversation {
            index = 0 //表示新消息
            data.insert(name, at: 1)
        }
        save()
        return index
    }
    
    func selected(index: Int) {
        let model = data[index]
        data.remove(at: index)
        data.insert(model, at: 0)
        save()
    }
}
