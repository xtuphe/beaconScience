//
//  ChatRoomVC.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/12.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class ChatRoomVC: UIViewController {
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    var leftDelegate = LeftTableViewDelegate()
    var rightDelegate = RightTableViewDelegate()
    var message = MessageCenter.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftTableView.delegate = leftDelegate
        leftTableView.dataSource = leftDelegate
        rightTableView.delegate = rightDelegate
        rightTableView.dataSource = rightDelegate
        rightDelegate.data = message.contentArray
        leftTableView.rowHeight = UITableViewAutomaticDimension
        rightTableView.rowHeight = UITableViewAutomaticDimension
        leftTableView.estimatedRowHeight = 300
        rightTableView.estimatedRowHeight = 300
        leftTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        rightTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        leftTableView.register(UINib.init(nibName: "ChatUserListCell", bundle: nil), forCellReuseIdentifier: "ChatUserListCell")
        rightTableView.register(UINib.init(nibName: "ChatBaseCell", bundle: nil), forCellReuseIdentifier: "ChatBaseCell")
        setupNotification()
        
    }
    
    func setupNotification(){
        NotificationCenter.default.addObserver(forName: notiName(name: "ChatRoomNeedsRefresh"), object: nil, queue: nil) { (noti) in
            self.leftTableView.reloadData()
            self.rightTableView.reloadData()
        }
    }
}


func listData() -> Array<InfoModel> {
    
    
    
    let welcomer = InfoModel.init(rawString: "name:Xtuphe event:welcome job:welcomer age:18 job:Programer male:false avatar:Avatar")
    let listArray = [welcomer]
    return listArray
    
}

class LeftTableViewDelegate: NSCoder, UITableViewDelegate, UITableViewDataSource {
    var data = listData()
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUserListCell")! as! ChatUserListCell
        cell.model = data[indexPath.row]
        cell.refresh()
        return cell
    }
    
    
}

class RightTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    var data : Array<MessageModel>?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBaseCell")! as! ChatBaseCell
        cell.model = data![indexPath.row]
        cell.refresh()
        return cell
    }
    
    
}
 
