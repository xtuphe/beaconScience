//
//  BonusVC.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/9/27.
//  Copyright © 2018 Xtuphe's. All rights reserved.
//

import UIKit

class BonusVC: UIViewController {

    var amount : Double!
    @IBOutlet weak var openButton: UIImageView!
    @IBOutlet weak var upperLid: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upperLid.layer.anchorPoint = CGPoint.init(x:0.5, y: 0)
        amountLabel.text = "获得$\(amount ?? 1)!"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animationStart()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: {})
    }
    
    func animationStart() {
        UIView.animate(withDuration: 0.25, animations: {
            self.upperLid.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi)/2, 1, 0, 0)
            self.openButton.layer.zPosition = 100
            self.openButton.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi)/2, 0, 1, 0)
        }) { (finished) in
            self.upperLid.image = UIImage.init(named: "BonusUp2")
            self.amountLabel.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.upperLid.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 1, 0, 0)
            }
            self.closeButton.isHidden = false
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
