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

func statusBarHeight() -> CGFloat{
    return UIApplication.shared.statusBarFrame.size.height
}

func tabBarHeight() -> CGFloat{
    return UITabBarController().tabBar.frame.size.height
}

extension UIColor {
    class func rgb(hex:UInt) -> UIColor {
        return UIColor(
            red:    CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green:  CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue:   CGFloat(hex & 0x0000FF) / 255.0,
            alpha:  CGFloat(1.0)
        )
    }
    
    class func background(num:Int) -> UIColor {
        let d = CGFloat(num)
        return UIColor.init(red: d/255.0, green: d/255.0, blue: d/255.0, alpha: 1)
    }
}

extension UIView {
    class func loadFromNib(nibName:String) -> UIView?{
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
