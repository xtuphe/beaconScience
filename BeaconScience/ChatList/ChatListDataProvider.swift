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
    
    var data : Array<InfoModel>
    var fileName = "Intro1"
    var index = 0
    let fileKey = Key<String>("ChatListFileKey")
    let indexKey = Key<Int>("ChatListIndexKey")
    
    init() {
        
        if Defaults.shared.has(fileKey) {
            fileName = Defaults.shared.get(for: fileKey)!
        }
        
        if Defaults.shared.has(indexKey) {
            index = Defaults.shared.get(for: indexKey)!
        }
        
        data = [InfoModel.init(rawString: "name:Xtuphe avatar:Avatar")]
        
        let fileManager = FileManager.default
        guard let directory =
            fileManager.urls(for: .libraryDirectory,
                             in: .userDomainMask).first
            else { return }
        let url = directory.appendingPathComponent(
            "SavedGames/ChatList")
        
        if fileManager.fileExists(atPath: url.path) {
            data = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as! Array<InfoModel>
            _ = try? fileManager.removeItem(at: url)
        }
    }
    
    func save() {
        
        Defaults.shared.set(fileName, for: fileKey)
        Defaults.shared.set(index, for: indexKey)
        
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
    
    func updateIndex() {
        Defaults.shared.set(index, for: indexKey)
    }
    
}
