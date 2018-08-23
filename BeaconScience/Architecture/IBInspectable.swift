//
//  IBInspectable.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/2/26.
//  Copyright © 2018年 Xtuphe's. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue > 0 ? newValue : 0
        }
    }

    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }

}

extension UIButton {
    @IBInspectable var mainColor: UIColor {
        get {
            return self.mainColor
        }
        set {
            let image = UIImage.init(color: newValue, size: frame.size)
            setBackgroundImage(image, for: UIControlState.normal)
        }
    }
    
    @IBInspectable var disableColor: UIColor {
        get {
            return self.disableColor
        }
        set {
            let image = UIImage.init(color: newValue, size: frame.size)
            setBackgroundImage(image, for: UIControlState.disabled)
        }
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

@IBDesignable class IBDesignableView: UIView {
    
}
