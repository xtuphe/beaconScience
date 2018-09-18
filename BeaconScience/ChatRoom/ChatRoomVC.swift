//
//  ChatRoomVC.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/12.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit
import AMPopTip

class ChatRoomVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    var choiceView: ChoiceTableView = ChoiceTableView()
    
    var name = Conversations.shared.data[0] as! String {
        didSet {
            loadSaves()
            Conversations.shared.onSightName = name
        }
    }
    var tableData : [MessageModel] = []
    let popTip = PopTip()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        setupNotification()
        setupMessageCenter()
        name = Conversations.shared.data[0] as! String
        choiceView.setup()
        setupPoptip()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "ChatListCell", bundle: nil), forCellWithReuseIdentifier: "ChatListCell")
    }
    
    func setupTableView(){
        tableView.tintColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.register(UINib.init(nibName: "ChatBaseCell", bundle: nil), forCellReuseIdentifier: "ChatBaseCell")
        tableView.register(UINib.init(nibName: "ChatChoiceCell", bundle: nil), forCellReuseIdentifier: "ChatChoiceCell")
        tableView.register(UINib.init(nibName: "ChatChosenCell", bundle: nil), forCellReuseIdentifier: "ChatChosenCell")
        tableView.register(UINib.init(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        tableView.register(UINib.init(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")

        tableView.backgroundColor = UIColor.background(num: 240)
    }
    
    func setupPoptip() {
        popTip.bubbleColor = UIColor.background(num: 40)
        popTip.textColor = UIColor.white
    }
    
    func setupNotification(){
        NotificationCenter.default.addObserver(forName: notiName(name: "ChatRoomNeedsRefresh"), object: nil, queue: nil) { (noti) in
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: notiName(name: "ChoiceViewShouldDismiss"), object: nil, queue: nil) { (noti) in
            //防止手快
            self.choiceView.isUserInteractionEnabled = false
            self.tableView.scrollToRow(at: IndexPath.init(row: self.tableData.count - 1, section: 0), at: .bottom, animated: true)
            _ = delay(1, task: { [unowned self] in
                self.choiceView.data = []
                self.tableView.tableFooterView = nil
            })
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
    
    //修改StatusBar为白色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

//MARK: - 消息中心代理

extension ChatRoomVC: MessagesDelegate {

    func presentChoiceView() {
        choiceView.frame = CGRect.init(x: 0, y: 0, width: screenWidth(), height: choiceView.contentSize.height)
        choiceView.reloadData()
        choiceView.isUserInteractionEnabled = true
        choiceView.frame = CGRect.init(x: 0, y: 0, width: screenWidth(), height: choiceView.height() + 10)
        tableView.tableFooterView = choiceView
        tableView.setContentOffset(CGPoint.init(x:0, y:tableView.contentSize.height - (screenHeight() - collectionView.frame.size.height - tabBarHeight())), animated: true)
    }
    
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
        
        if message.type == .choice {
            choiceView.data.append(message)
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
        
        _ = delay(0.3, task: { [unowned self] in
            //暂时固定其他人的消息在1的位置
            self.popTipMessage(message: message, index: 1)
        })
    }
    
    func popTipMessage(message:MessageModel, index: Int) {
        let cell = collectionView.cellForItem(at: IndexPath.init(row: index, section: 0))!
        let frame = cell.convert(cell.bounds, to: view)
        popTip.show(text: message.content!, direction: .down, maxWidth: 250, in: view, from: frame)
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
        //首先清空choice view
        choiceView.data = []
        choiceView.reloadData()
        
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
        if savedModel.type == .image {
            messageModel.image = savedModel.content
        }
        return messageModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableData[indexPath.row]
        switch model.type {
        case .choice:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatChoiceCell")! as! ChatChoiceCell
            cell.model = model
            return cell
        case .chosen:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatChosenCell")! as! ChatChosenCell
            cell.model = model
            return cell
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell")! as! ImageCell
            cell.chatType()
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

