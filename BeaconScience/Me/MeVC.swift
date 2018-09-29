//
//  MeVC.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/15.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

//  头像 姓名
//  资金
//  通知（关键日志）
//  模拟器
//  reset

import UIKit

class MeVC: UITableViewController {

    var data : Array<Array<String>>!
    var avatarCell : MeAvatarCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        modalPresentationStyle = .currentContext
        setupTableView()
        setupInfoCell()
        data = [["头像姓名"], ["钱包"], ["重置"], ["Bonus$", "Advertisement"]]
        
        _ = GoogleAds.shared
    }

    //修改StatusBar为黑色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    func setupTableView() {
        tableView.register(UINib.init(nibName: "MeItemCell", bundle: nil), forCellReuseIdentifier: "MeItemCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.background(num: 240)
        tableView.separatorStyle = .none
    }

    func setupInfoCell() {
        let nib = UINib.init(nibName: "MeAvatarCell", bundle: nil)
        avatarCell = nib.instantiate(withOwner: self, options: nil).first as? MeAvatarCell
        // load name
        avatarCell.avatarImageView.image = UIImage.init(named: "BeaconNight")
        // load avatar
        avatarCell.nameLabel.text = "灯塔科技"
        
    }
    
}

extension MeVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = data[section]
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let separator = UIView()
        separator.backgroundColor = UIColor.clear
        return separator
    }
    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 20
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return avatarCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeItemCell") as! MeItemCell
        let array = data[indexPath.section]
        let title = array[indexPath.row]
        cell.itemLabel.text = title
        cell.itemImageView.image = UIImage.init(named: title)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
