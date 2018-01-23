//
//  NotificationCenterX.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/22.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import Foundation
import UserNotifications

public func registerNoti(timeInterval:TimeInterval, title:String, body:String){
    let content = UNMutableNotificationContent()
    content.title = NSString.localizedUserNotificationString(forKey:
        title, arguments: nil)
    content.body = NSString.localizedUserNotificationString(forKey:
        body, arguments: nil)
    
    // Deliver the notification in five seconds.
    content.sound = UNNotificationSound.default()
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                    repeats: false)
    
    // Schedule the notification.
    let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
    let center = UNUserNotificationCenter.current()
    center.add(request, withCompletionHandler: nil)
}
