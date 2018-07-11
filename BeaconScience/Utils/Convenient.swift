//
//  Convenient.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/7/11.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import Foundation

func printLog<T>(message: T,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line){
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}
