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
    
    
    content.sound = UNNotificationSound.default()
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                    repeats: false)
    
    // Schedule the notification.
    let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
    
    
    let center = UNUserNotificationCenter.current()
    center.add(request) { (error) in
        print("Notification Registered", error as Any)
    }
}

public func removeNoti(identifier:String){
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [identifier])
}

public func removeAllNoti(){
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
}

public class NotificationCenterX: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationCenterX.init()

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 前台通知转发
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "testNoti"), object: notification)
        print("Will present : foreground")
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 后台通知点击时触发
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "testNoti"), object: response)
        print("Did receive : background")
    }
    
    
    
}

public func notiName(name: String) -> Notification.Name {
    return NSNotification.Name(rawValue: name)
}
