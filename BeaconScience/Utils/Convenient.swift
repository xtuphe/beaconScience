//
//  Convenient.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/7/11.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import Foundation
import UIKit

func printLog<T>(message: T,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line){
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

func screenWidth() -> CGFloat{
    return UIScreen.main.bounds.width
}

func screenHeight() -> CGFloat{
    return UIScreen.main.bounds.height
}

extension UIView {
    class func loadFromNib(nibName:String) -> UIView?{
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
