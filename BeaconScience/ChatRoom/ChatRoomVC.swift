//
//  ChatRoomVC.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/12.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class ChatRoomVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    var userData = ChatListData.shared.data
    var messageCenter = MessageCenter.shared
    var infoModel = ChatListData.shared.data[0] as! InfoModel {
        didSet {
            loadSaves()
            
        }
    }
    var tableData : [MessageModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        setupNotification()
        setupMessageCenter()
        ChatListData.shared.save()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "ChatListCell", bundle: nil), forCellWithReuseIdentifier: "ChatListCell")
    }
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.register(UINib.init(nibName: "ChatBaseCell", bundle: nil), forCellReuseIdentifier: "ChatBaseCell")
        tableView.register(UINib.init(nibName: "ChatChoiceCell", bundle: nil), forCellReuseIdentifier: "ChatChoiceCell")
    }
    
    func setupNotification(){
        NotificationCenter.default.addObserver(forName: notiName(name: "ChatRoomNeedsRefresh"), object: nil, queue: nil) { (noti) in
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    func setupMessageCenter(){
        messageCenter.whatsNext()
        messageCenter.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//MARK: - 消息中心代理

extension ChatRoomVC: MessageCenterDelegate {
    
    func newConversation(_ infoModel: InfoModel) {


    }

    func newMessageReceived(_ message: MessageModel) {
        //其他人的信息
        if message.name != nil {
            let index = ChatListData.shared.newConversation(name: message.name!, avatar: "Avatar")
            newMessageHandle(index: index, content: message.content!, name: message.name!)
            return
        }
        
        if infoModel.name != messageCenter.infoModel?.name {
            let index = ChatListData.shared.newConversation(name: (messageCenter.infoModel?.name)!, avatar: (messageCenter.infoModel?.avatar)!)
            newMessageHandle(index: index, content: message.content!, name: (messageCenter.infoModel?.name)!)
            return
        }
        
        tableData.append(message)
        tableView.reloadData()
        
        if tableView.contentOffset.y < tableView.contentSize.height - tableView.frame.size.height {
            _ = delay(0.1) { [unowned self] in
                self.tableView.scrollToRow(at: IndexPath.init(row: self.tableData.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    func newMessageHandle(index: Int, content: String, name: String) {
        if index == 0 {
            collectionView.insertItems(at: [IndexPath.init(row: 1, section: 0)])
        } else if index > 0 {
            collectionView.moveItem(at: IndexPath.init(row: index, section: 0), to: IndexPath.init(row: 1, section: 0))
        }
        
        showMessage(name: name, content: content)
        let unreadKey = Key<Int>("UnreadKey\(name)")
        var count = 0
        if Defaults.shared.has(unreadKey) {
            count = Defaults.shared.get(for: unreadKey)!
        }
        count += 1
        Defaults.shared.set(count, for: unreadKey)
    }
}

//MARK: - CollectionView 代理

extension ChatRoomVC : UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        cell.model = userData[indexPath.row] as? InfoModel
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ChatListData.shared.selected(index: indexPath.row)
        userData = ChatListData.shared.data
        infoModel = userData[0] as! InfoModel
        let unreadKey = Key<Int>("UnreadKey\(infoModel.name)")
        Defaults.shared.set(0, for: unreadKey)
        collectionView.moveItem(at: indexPath, to: IndexPath.init(row: 0, section: 0))
    }
    
}

//MARK: - TableView 代理

extension ChatRoomVC : UITableViewDelegate, UITableViewDataSource {
    
    func loadSaves() {
        let indexKey = Key<Int>("\(infoModel.name)SavedIndex")
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
        tableData = savedData
        tableView?.reloadData()
        tableView?.scrollToRow(at: IndexPath.init(row: tableData.count - 1, section: 0), at: .bottom, animated: false)
    }
    
    func savedMessageWith(index : Int) -> MessageModel {
        let key = Key<SavedMessage>("\(index)")
        let defaults = Defaults.init(userDefaults: UserDefaults.init(suiteName: "beaconScience.\(infoModel.name)")!)
        let savedModel = defaults.get(for: key)!
        var messageModel = MessageModel.init()
        messageModel.content = savedModel.content
        messageModel.type = savedModel.type
        return messageModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableData[indexPath.row]
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

