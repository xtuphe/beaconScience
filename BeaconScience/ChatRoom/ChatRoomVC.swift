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
        leftTableView.delegate = leftDelegate;
        leftTableView.dataSource = leftDelegate;
        rightTableView.delegate = rightDelegate;
        rightTableView.delegate = rightDelegate;
        rightDelegate.data = message.contentArray;
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

class LeftTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    var data : Array<InfoModel>?
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ChatUserListCell")!
    }
    
    
}

class RightTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    var data : Array<MessageModel>?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ChatBaseCell")!
    }
    
    
}
 