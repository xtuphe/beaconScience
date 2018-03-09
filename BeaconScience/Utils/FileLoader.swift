//
//  FileLoader.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/29.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

public func loadContentFile(name:String) -> NSString {
    let filePath = Bundle.main.path(forResource: name, ofType: "txt")
    let fileUrl = URL(fileURLWithPath: filePath!)
    let fileContent = NSData.init(contentsOf: fileUrl)
    return NSString(data: fileContent! as Data, encoding: String.Encoding.utf8.rawValue)!
}
