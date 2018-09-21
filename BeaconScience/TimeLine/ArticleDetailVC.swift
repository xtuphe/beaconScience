//
//  ArticleDetailVC.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/8/27.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit
import MarkdownView

class ArticleDetailVC: UIViewController {

    let mdView = MarkdownView()
    var fileName : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        mdView.frame = view.bounds
        view.addSubview(mdView)
        setupCloseButton()
        loadMd()
    }
    
    func loadMd() {
        let filePath = Bundle.main.path(forResource: fileName, ofType: "md")
        let fileUrl = URL(fileURLWithPath: filePath!)
        let fileContent = NSData.init(contentsOf: fileUrl)
        let str = NSString(data: fileContent! as Data, encoding: String.Encoding.utf8.rawValue)!
        mdView.load(markdown: str as String)
    }
    
    func setupCloseButton() {
        let button = PMSuperButton.init(frame: CGRect.init(x: screenWidth()/2 - 22, y: screenHeight() - tabBarHeight() - 80, width: 44, height: 44))
        view.addSubview(button)
//        button.shadowRadius = 5
//        button.shadowColor = .gray
//        button.shadowOpacity = 1
//        button.shadowOffset = .init(width: 3, height: 3)
        button.animatedScaleWhenHighlighted = 10
        button.backgroundColor = UIColor.black
        button.setTitle("╳", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(ArticleDetailVC.closeTapped), for: .touchUpInside)
        button.cornerRadius = 22
    }
    
    @objc func closeTapped() {
        dismiss(animated: true, completion: {})
    }
}
