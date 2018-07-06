//
//  NotiView.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/7/5.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

func showMessage(name: String, content: String) {
    let view = MessageView.viewFromNib(layout: .cardView)
    view.configureTheme(.info)
    view.configureDropShadow()
    view.configureContent(title: name, body: content)
    SwiftMessages.show(view: view)
}
