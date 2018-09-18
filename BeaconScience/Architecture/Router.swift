//
//  Router.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/27.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class Router: NSObject {
    
    class func show(controller:UIViewController) {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController!
        rootVC?.show(controller, sender: nil)
    }
    
    class func rootVC() -> UIViewController {
        return (UIApplication.shared.keyWindow?.rootViewController!)!
    }

}
