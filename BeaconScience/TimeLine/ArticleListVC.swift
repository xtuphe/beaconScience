//
//  ArticleListVC.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/11/8.
//  Copyright © 2018 Xtuphe's. All rights reserved.
//

import UIKit

class ArticleListVC: UITableViewController {
    
    var data = ["BeaconScience语法", "新员工手册"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
    }
    
    //修改StatusBar为黑色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func setupCloseButton() {
        let button = PMSuperButton.init(frame: CGRect.init(x: screenWidth()/2 - 22, y: screenHeight() - tabBarHeight() - 140, width: 44, height: 44))
        view.addSubview(button)
        button.animatedScaleWhenHighlighted = 10
        button.backgroundColor = UIColor.black
        button.setTitle("╳", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(ArticleListVC.closeTapped), for: .touchUpInside)
        button.cornerRadius = 22
    }
    
    @objc func closeTapped() {
        dismiss(animated: true, completion: {})
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let articleVC = ArticleDetailVC()
        articleVC.fileName = (cell?.textLabel?.text)!
        self.show(articleVC, sender: nil)
    }
    
}
