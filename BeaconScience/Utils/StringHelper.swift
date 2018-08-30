//
//  StringHelper.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/3.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import Foundation
import UIKit

func strHeight(string:String, font:UIFont, width:CGFloat) -> CGFloat {
    return string.boundingRect(with: CGSize.init(width: width, height: 8888), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:font], context: nil).height
}


