//
//  TimeLineVC.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/1/15.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class TimeLineVC: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
    
    var data : Array<MessageModel> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        GoogleAds.shared.addBannerAdTo(view: headerView)
    }

    //修改StatusBar为黑色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        data = TimeLine.shared.data
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarItem.badgeValue = nil
        let key = Key<Bool>("RedDotTimeLine")
        Defaults.shared.set(false, for: key)
    }
    
    func setupTableView() {
        tableView.register(UINib.init(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        tableView.register(UINib.init(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        tableView.register(UINib.init(nibName: "PlainTextCell", bundle: nil), forCellReuseIdentifier: "PlainTextCell")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data[indexPath.row]
        switch model.type {
        case .quanImage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.model = model
            return cell
        case .quanArticle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
            cell.model = model
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlainTextCell", for: indexPath) as! PlainTextCell
            cell.model = model
            return cell
        }
    }

}
