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
    var messageCenter = MessageCenter(index: ChatListData.shared.index, file: ChatListData.shared.fileName)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViews()
        setupNotification()
        setupMessageCenter()
        ChatListData.shared.save()
    }
    
    func setupTableViews(){
        leftTableView.delegate = leftDelegate
        leftTableView.dataSource = leftDelegate
        rightTableView.delegate = rightDelegate
        rightTableView.dataSource = rightDelegate
        leftTableView.rowHeight = UITableViewAutomaticDimension
        rightTableView.rowHeight = UITableViewAutomaticDimension
        leftTableView.estimatedRowHeight = 300
        rightTableView.estimatedRowHeight = 300
        leftTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        rightTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        leftTableView.register(UINib.init(nibName: "ChatUserListCell", bundle: nil), forCellReuseIdentifier: "ChatUserListCell")
        rightTableView.register(UINib.init(nibName: "ChatBaseCell", bundle: nil), forCellReuseIdentifier: "ChatBaseCell")
        rightTableView.register(UINib.init(nibName: "ChatChoiceCell", bundle: nil), forCellReuseIdentifier: "ChatChoiceCell")
        rightDelegate.loadSaves()
    }
    
    func setupNotification(){
        NotificationCenter.default.addObserver(forName: notiName(name: "ChatRoomNeedsRefresh"), object: nil, queue: nil) { (noti) in
            self.leftTableView.reloadData()
            self.rightTableView.reloadData()
        }
    }
    
    func setupMessageCenter(){
        messageCenter.whatsNext()
        messageCenter.delegate = self
        rightDelegate.messageCenter = messageCenter
    }
}

extension ChatRoomVC: NewMessageDelegate {
    func newMessageReceived(_ message: MessageModel) {
        //其他人的信息
        if message.name != nil {
            //TODO
            return
        }
        
        rightDelegate.data.append(message)
        rightTableView.reloadData()
        
        if rightTableView.contentOffset.y < rightTableView.contentSize.height - rightTableView.frame.size.height {
            _ = delay(0.1) { [unowned self] in
                self.rightTableView.scrollToRow(at: IndexPath.init(row: self.rightDelegate.data.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
}

class LeftTableViewDelegate: NSCoder, UITableViewDelegate, UITableViewDataSource {
    var data = ChatListData.shared.data

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
    var data : [MessageModel] = []
    var infoModel = ChatListData.shared.data.first
    weak var messageCenter : MessageCenter?
    
    func loadSaves() {
        let indexKey = Key<Int>("\(infoModel!.name)SavedIndex")
        var savedIndex = 0
        if Defaults.shared.has(indexKey) {
            savedIndex = Defaults.shared.get(for: indexKey)!
        } else {
            return
        }
        
        var savedData : [MessageModel] = []
        if savedIndex > 20 {
            for index in (savedIndex - 20)...savedIndex {
                savedData.append(savedMessageWith(index: index))
            }
        } else {
            for index in 1...savedIndex {
                savedData.append(savedMessageWith(index: index))
            }
        }
        data = savedData
    }
    
    func savedMessageWith(index : Int) -> MessageModel {
        let key = Key<SavedMessage>("\(index)")
        let defaults = Defaults.init(userDefaults: UserDefaults.init(suiteName: "beaconScience.\(infoModel!.name)")!)
        let savedModel = defaults.get(for: key)!
        let messageModel = MessageModel.init()
        messageModel.content = savedModel.content
        messageModel.type = savedModel.type
        return messageModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data[indexPath.row]
        switch model.type {
        case .choice, .chosen, .invalid:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatChoiceCell")! as! ChatChoiceCell
            cell.model = model
            cell.messageCenter = messageCenter
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBaseCell")! as! ChatBaseCell
            cell.model = model
            cell.refresh()
            return cell
        }
    }
    
    
}
 
