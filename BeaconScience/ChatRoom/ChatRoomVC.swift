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
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipTopConstraint: NSLayoutConstraint!
    
    var choiceView: ChoiceTableView = ChoiceTableView()
    var choiceCache: [String] = []
    var currentName = Conversations.shared.firstName {
        didSet {
            loadSaves()
        }
    }
    var tableData : [MessageModel] = []
    let popTip = PopTip()
    var visible : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        setupNotification()
        setupMessageCenter()
        currentName = Conversations.shared.data[0]
        choiceView.setup()
        setupPoptip()
        setupRedDotNotification()
        checkRedDotSaves()
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
        
        NotificationCenter.default.addObserver(forName: notiName(name: .ChatRoomNeedsRefresh), object: nil, queue: nil) { (noti) in
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: notiName(name: .ChoiceViewShouldDismiss), object: nil, queue: nil) { (noti) in
            //防止手快
            self.choiceView.isUserInteractionEnabled = false
            self.choiceView.data = []
            self.tableView.tableFooterView = nil
            
            let model = noti.object as! MessageModel
            //检查是否有选中tip
            if model.tip != nil {
                _ = delay(1, task: {
                    self.showTipMessage(content: model.tip!)
                })
            }
            //缓存已选
            let combinedStr = model.content + String(model.index)
            self.choiceCache.append(combinedStr)
            if self.choiceCache.count > 20 {
                self.choiceCache.remove(at: 0)
            }
            
        }
    }

    
    func setupMessageCenter(){
        Messages.shared.delegate = self
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visible = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visible = true
        tabBarItem.badgeValue = nil
        let key = Key<Bool>("RedDotChat")
        Defaults.shared.set(false, for: key)
    }
    
    //修改StatusBar为白色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension ChatRoomVC {
    
    func setupRedDotNotification() {
        NotificationCenter.default.addObserver(forName: notiName(name: .RedDotChat), object: nil, queue: nil) { (noti) in
            self.showRedDot(index:0)
        }
        NotificationCenter.default.addObserver(forName: notiName(name: .RedDotTimeLine), object: nil, queue: nil) { (noti) in
            self.showRedDot(index:1)
        }
        NotificationCenter.default.addObserver(forName: notiName(name: .RedDotMine), object: nil, queue: nil) { (noti) in
            self.showRedDot(index:2)
        }
    }
    
    func checkRedDotSaves() {
        let key1 = Key<Bool>("RedDotChat")
        let key2 = Key<Bool>("RedDotTimeLine")
        let key3 = Key<Bool>("RedDotMine")
        if Defaults.shared.get(for: key1) ?? false {
            self.showRedDot(index:0)
        }
        if Defaults.shared.get(for: key2) ?? false {
            self.showRedDot(index: 1)
        }
        if Defaults.shared.get(for: key3) ?? false {
            self.showRedDot(index: 2)
        }
    }
    
    func showRedDot(index:Int) {
        let item = (tabBarController?.tabBar.items![index])!
        item.badgeColor = .clear
        item.setBadgeTextAttributes(
            [NSAttributedStringKey.font.rawValue : UIFont.boldSystemFont(ofSize: 20),
             NSAttributedStringKey.foregroundColor.rawValue : UIColor.red ],
            for: UIControlState.normal)
        item.badgeValue = "●"
        //保存红点
        let keyNames = ["RedDotChat", "RedDotTimeLine", "RedDotMine"]
        let key = Key<Bool>(keyNames[index])
        Defaults.shared.set(true, for: key)
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
        if tableView.contentOffset.y < tableView.contentSize.height - tableView.frame.size.height {
            tableView.setContentOffset(CGPoint.init(x:0, y:tableView.contentSize.height - (screenHeight() - collectionView.frame.size.height - tabBarHeight())), animated: true)
        }
    }
    
    func newMessageReceived(_ message: MessageModel) {
        if message.tip != nil && message.type != .choice && message.type != .chosen {
            showTipMessage(content: message.tip!)
        }
        
        //当前聊天页面其他人信息
        if message.type == .others {
            let index = Conversations.shared.newConversation(name: message.name)
            newMessageHandle(index: index, message: message, name: message.name)
            return
        }
        //其他人页面当前聊天人信息
        if currentName != Messages.shared.name {
            let index = Conversations.shared.newConversation(name: Messages.shared.name)
            newMessageHandle(index: index, message: message, name: Messages.shared.name)
            return
        }
        
        if message.type == .choice {
            oneMoreChoice(message: message)
            return
        }
        
        tableData.append(message)
        tableView.reloadData()

        if message.type == .chosen  {
            _ = delay(0.25) { [unowned self] in
            self.tableView.scrollToRow(at: IndexPath.init(row: self.tableData.count - 1, section: 0), at: .bottom, animated: false)
            }
            return
        }
        
        if tableView.contentOffset.y < tableView.contentSize.height - tableView.frame.size.height{
            _ = delay(0.1) { [unowned self] in
                self.tableView.scrollToRow(at: IndexPath.init(row: self.tableData.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
        
        if !visible && message.type == .normal{
            showRedDot(index: 0)
            showMessage(name: message.name, content: message.content)
        }
    }
    
    func oneMoreChoice(message: MessageModel) {
        let combinedStr = message.content! + String(message.index)
        if choiceCache.contains(combinedStr) {
            return
        }
        choiceView.data.append(message)
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
    
    //其他人的消息
    func popTipMessage(message:MessageModel, index: Int) {
        let cell = collectionView.cellForItem(at: IndexPath.init(row: index, section: 0))!
        let frame = cell.convert(cell.bounds, to: view)
        popTip.show(text: message.content!, direction: .down, maxWidth: 250, in: view, from: frame)
        let unreadKey = Key<Int>("UnreadKey\(currentName)")
        var count = 0
        if Defaults.shared.has(unreadKey) {
            count = Defaults.shared.get(for: unreadKey)!
        }
        count += 1
        Defaults.shared.set(count, for: unreadKey)
    }
    
    //系统提示消息
    func showTipMessage(content: String) {
        tipLabel.text = content
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.tipTopConstraint.constant = 10
            self.view.layoutIfNeeded()
        }) { (finished) in
            _ = delay(2, task: { [unowned self] in
                UIView.animate(withDuration: 0.2, animations: {
                    self.tipTopConstraint.constant = -50
                    self.view.layoutIfNeeded()
                })
            })
        }
    }
}

//MARK: - CollectionView 代理

extension ChatRoomVC : UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Conversations.shared.data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        cell.name = Conversations.shared.data[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //当前会话
            return
        }
        //首先清空choice view
        choiceView.data = []
        choiceView.reloadData()
        tableView.tableFooterView = nil
        
        Conversations.shared.selected(index: indexPath.row)
        currentName = Conversations.shared.firstName
        printLog(message: ".....selecting name: \(currentName)")

        collectionView.moveItem(at: indexPath, to: IndexPath.init(row: 0, section: 0))

        if Messages.shared.safeToLoad(name: currentName) {
            Messages.shared.reload(name: currentName)
            if Messages.shared.task == nil {
                Messages.shared.whatsNext()
            }
        }
    }
}

//MARK: - TableView 代理

extension ChatRoomVC : UITableViewDelegate, UITableViewDataSource {
    
    func loadSaves() {
        let indexKey = Key<Int>("\(currentName)SavedCount")
        var savedCount = 0
        if Defaults.shared.has(indexKey) {
            savedCount = Defaults.shared.get(for: indexKey)!
        } else {
            tableData = []
            tableView.reloadData()
            return
        }
        
        var savedData : [MessageModel] = []
        if savedCount > 50 {
            for index in (savedCount - 50)...savedCount {
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
        let defaults = Defaults.init(userDefaults: UserDefaults.init(suiteName: "beaconScience.\(currentName)")!)
        let savedModel = defaults.get(for: key)!
        var messageModel = MessageModel.init()
        messageModel.content = savedModel.content
        messageModel.type = savedModel.type
        messageModel.name = savedModel.name
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
        case .article:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell")! as! ArticleCell
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

