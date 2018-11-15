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
    
    class func presentBonus(amount:Double) {
        let bonusVC = BonusVC.init(nibName: "BonusVC", bundle: nil)
        bonusVC.modalPresentationStyle = .overCurrentContext
        bonusVC.amount = amount
        Router.rootVC().present(bonusVC, animated: true, completion: {})
    }
    
    class func presentFilesVC() {
        let filesVC = ArticleListVC()
        Router.show(controller: filesVC)
    }

}

extension UIView {
    func currentVC() -> UIViewController {
        var vc : UIViewController?
        var nextResponder = self as UIResponder
        while (nextResponder.next != nil) {
            nextResponder = nextResponder.next!
            print("......\(nextResponder)")
            if nextResponder.isKind(of: UIViewController.self) {
                vc = nextResponder as? UIViewController
                break
            }
        }
        return vc ?? Router.rootVC()
    }
    
    func currentTableView() -> UITableView {
        var tableView : UITableView?
        var nextResponder = self as UIResponder
        while nextResponder.next != nil {
            nextResponder = nextResponder.next!
            print("...\(nextResponder)")
            if nextResponder.isKind(of: UITableView.self) {
                tableView = nextResponder as? UITableView
                break
            }
        }
        return tableView ?? UITableView()
    }
}
