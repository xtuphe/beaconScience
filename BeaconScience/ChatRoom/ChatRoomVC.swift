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
    var name = Conversations.shared.data[0] as! String {
        didSet {
            loadSaves()
            Conversations.shared.onSightName = name
        }
    }
    var tableData : [MessageModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        setupNotification()
        setupMessageCenter()
        name = Conversations.shared.data[0] as! String
        
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
        Messages.shared.delegate = self
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Conversations.shared.onSightName = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Conversations.shared.onSightName = name
    }
}

//MARK: - 消息中心代理

extension ChatRoomVC: MessagesDelegate {
    

    func newMessageReceived(_ message: MessageModel) {
        //其他人的信息
        if message.name != nil {
            let index = Conversations.shared.newConversation(name: message.name!)
            newMessageHandle(index: index, message: message, name: message.name!)
            return
        }
        
        if name != Messages.shared.name {
            let index = Conversations.shared.newConversation(name: Messages.shared.name)
            newMessageHandle(index: index, message: message, name: Messages.shared.name)
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
    
    func newMessageHandle(index: Int, message: MessageModel, name: String) {
        if index == 0 {
            collectionView.insertItems(at: [IndexPath.init(row: 1, section: 0)])
        } else if index > 0 {
            collectionView.moveItem(at: IndexPath.init(row: index, section: 0), to: IndexPath.init(row: 1, section: 0))
        }
        if message.type == .choice {
            return
        }
        showMessage(name: name, content: message.content!)
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
        return Conversations.shared.data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        cell.name = Conversations.shared.data[indexPath.row] as? String
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Conversations.shared.selected(index: indexPath.row)
        name = Conversations.shared.data[0] as! String
        Messages.shared.reload(name: name)
        
        printLog(message: ".....selecting name: \(name)")

        collectionView.moveItem(at: indexPath, to: IndexPath.init(row: 0, section: 0))

        if Messages.shared.task == nil {
            Messages.shared.whatsNext()
        }
        
    }
    
}

//MARK: - TableView 代理

extension ChatRoomVC : UITableViewDelegate, UITableViewDataSource {
    
    func loadSaves() {
        let indexKey = Key<Int>("\(name)SavedCount")
        var savedCount = 0
        if Defaults.shared.has(indexKey) {
            savedCount = Defaults.shared.get(for: indexKey)!
        } else {
            tableData = []
            tableView.reloadData()
            return
        }
        
        var savedData : [MessageModel] = []
        if savedCount > 20 {
            for index in (savedCount - 20)...savedCount {
                savedData.append(getSavedMessageWith(index: index))
            }
        } else {
            for index in 1...savedCount {
                savedData.append(getSavedMessageWith(index: index))
            }
        }
        tableData = savedData
        tableView?.reloadData()
        tableView?.scrollToRow(at: IndexPath.init(row: tableData.count - 1, section: 0), at: .bottom, animated: false)
    }
    
    func getSavedMessageWith(index : Int) -> MessageModel {
        let key = Key<SavedMessage>("\(index)")
        let defaults = Defaults.init(userDefaults: UserDefaults.init(suiteName: "beaconScience.\(name)")!)
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
        case .choice, .chosen:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatChoiceCell")! as! ChatChoiceCell
            cell.model = model
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBaseCell")! as! ChatBaseCell
            cell.model = model
            cell.refresh()
            return cell
        }
    }
}

