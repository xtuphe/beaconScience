//
//  NotificationCenterX.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/22.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import Foundation
import UserNotifications

/*
 聊天页面内: 轮询, 有新消息直接显示
 应用内: 通知List
 应用歪: 通知
 
 */

enum NotiName : String {
    case ChatRoomNeedsRefresh = "ChatRoomNeedsRefresh"
    case ChoiceViewShouldDismiss = "ChoiceViewShouldDismiss"
    case RedDotTimeLine = "ShowTimeLineRedDot"
    case RedDotMine = "ShowMyRedDot"
    case RedDotChat = "ShowChatRedDot"
}

let notificationIdentifier = "NotificationIdentifier"

func registerNoti(timeInterval:TimeInterval, title:String, body:String){
    let content = UNMutableNotificationContent()
    content.title = NSString.localizedUserNotificationString(forKey:
        title, arguments: nil)
    content.body = NSString.localizedUserNotificationString(forKey:
        body, arguments: nil)
    
    
    content.sound = UNNotificationSound.default()
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                    repeats: false)
    
    // Schedule the notification.
    let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
    
    
    let center = UNUserNotificationCenter.current()
    center.add(request) { (error) in
        print("Notification Registered", error as Any)
    }
}

func removeNoti(identifier:String){
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [identifier])
}

func removeAllNoti(){
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
}

class NotificationCenterX: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationCenterX.init()

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 前台通知转发
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "testNoti"), object: notification)
        print("Will present : foreground")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 后台通知点击时触发
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "testNoti"), object: response)
        print("Did receive : background")
    }
}

func notiName(name: NotiName) -> Notification.Name {
    return NSNotification.Name(rawValue: name.rawValue)
}
