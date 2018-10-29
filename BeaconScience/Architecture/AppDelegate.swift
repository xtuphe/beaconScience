//
//  AppDelegate.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/11.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleMobileAds

/*
 firstTime
 load boss
 list add boss
 
 
 (检查新内容)
 load list
 load conversation
    load story
    load line
    timer
 
 
 */

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var wasActive : Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize the Google Mobile Ads SDK.
        // Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3038479336466621~7730942440")
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        printLog(message: "沙盒路径：\(path)")
        
        
        let center = UNUserNotificationCenter.current()
        center.delegate = NotificationCenterX.shared
        
        if #available(iOS 12.0, *) {
            center.requestAuthorization(options: [.alert, .badge, .sound, .provisional, .criticalAlert, .providesAppNotificationSettings]) { (granted, error) in
                if !granted {
                    print("Notification Needs granted")
                }
            }
        } else {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if !granted {
                    print("Notification Needs granted")
                }
            }
        }
        
        center.requestAuthorization(options: []) { (granted, error) in
            if !granted {
                print("Notification Needs granted")
            }
        }
        
        
        return true
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("Will Resign Active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        if Messages.shared.task != nil {
//            cancel(Messages.shared.task)
//            Messages.shared.task = nil
//        }
        print("Did Enter Background - Apple noti registered")
        if Messages.shared.nextModel != nil {
            if Messages.shared.nextModel?.type == .choice {
                return
            }
            registerNoti(timeInterval: Messages.shared.gap, title: Messages.shared.nextModel?.name ?? "?", body: Messages.shared.nextModel?.content ?? "???")
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Did Become Active - apple noti removed")
        removeAllNoti()
//        if wasActive {
//            Messages.shared.whatsNext()
//        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("Will Terminate - Session rearranged")
        Conversations.shared.rearrangeSessions()
    }


}

