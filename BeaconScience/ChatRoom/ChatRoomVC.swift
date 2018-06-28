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
    var messageCenter = MessageCenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViews()
        setupNotification()
        setupMessageCenter()
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
    }
    
    func setupNotification(){
        NotificationCenter.default.addObserver(forName: notiName(name: "ChatRoomNeedsRefresh"), object: nil, queue: nil) { (noti) in
            self.leftTableView.reloadData()
            self.rightTableView.reloadData()
        }
    }
    
    func setupMessageCenter(){
        messageCenter.getContents(fileName: "Empty")
        messageCenter.whatsNext()
        messageCenter.delegate = self
        rightDelegate.messageCenter = messageCenter
    }
}


func listData() -> Array<InfoModel> {
    
    
    
    let welcomer = InfoModel.init(rawString: "name:Xtuphe event:welcome job:welcomer age:18 job:Programer male:false avatar:Avatar")
    let listArray = [welcomer]
    return listArray
    
}

extension ChatRoomVC: NewMessageDelegate {
    func newMessageReceived(_ message: MessageModel) {
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
    var data : [MessageModel] = []
    weak var messageCenter : MessageCenter?
    var currentName = "Intro"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data[indexPath.row]
        if model.choice {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatChoiceCell")! as! ChatChoiceCell
            cell.model = model
            cell.messageCenter = messageCenter
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBaseCell")! as! ChatBaseCell
            cell.model = model
            cell.refresh()
            return cell
        }
        
        
    }
    
    
}
 
