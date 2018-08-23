//
//  ChoiceTableView.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/10.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

class ChoiceTableView: UITableView {

    var data : [MessageModel] = []
    
    func setup() {
        isScrollEnabled = false
        delegate = self
        dataSource = self
        register(UINib.init(nibName: "ChatChoiceCell", bundle: nil), forCellReuseIdentifier: "ChatChoiceCell")
    }
    
}

extension ChoiceTableView : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatChoiceCell") as! ChatChoiceCell
        cell.model = data[indexPath.row]
        return cell
    }
    
    
    
    
}
