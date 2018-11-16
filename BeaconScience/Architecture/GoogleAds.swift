//
//  GoogleAds.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/9/29.
//  Copyright © 2018 Xtuphe's. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GoogleAds : NSObject, GADInterstitialDelegate {
    static let shared = GoogleAds()
    var interstitial: GADInterstitial!
    
    override init() {
        super.init()
        interstitial = createAndLoadInterstitial()
        
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        /*
         production:
         ca-app-pub-3038479336466621/1362928925
         test:
         ca-app-pub-3940256099942544/4411468910
         */
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3038479336466621/1362928925")
//        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        Router.presentBonus(amount: 100)
    }
    
    func presentInterstitial() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: Router.rootVC())
        } else {
            printLog(message: "interstitial ad not ready")
        }
    }
}
