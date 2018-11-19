//
//  GoogleAds.swift
//  BeaconScience
//
//  Created by Xtuphe on 2018/9/29.
//  Copyright © 2018 Xtuphe's. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GoogleAds : NSObject, GADInterstitialDelegate, GADBannerViewDelegate, GADAdLoaderDelegate {
    
    static let shared = GoogleAds()
    var interstitial: GADInterstitial!
    var bannerView : GADBannerView!
    var adLoader : GADAdLoader!
    #if DEBUG
    let interstitialID = "ca-app-pub-3940256099942544/4411468910"
    let bannerID = "ca-app-pub-3940256099942544/2934735716"
    let nativeAd = "ca-app-pub-3940256099942544/3986624511"
    #else
    let interstitialID = "ca-app-pub-3038479336466621/1362928925"
    let bannerID = "ca-app-pub-3038479336466621/3371256922"
    let nativeAd = "ca-app-pub-3940256099942544/3986624511"
    //TODO: change nativeAd
    #endif
    
    
    override init() {
        super.init()
        interstitial = createAndLoadInterstitial()
        let bannerSize = GADAdSizeFromCGSize(CGSize.init(width: screenWidth(), height: 320))
        bannerView = GADBannerView(adSize: bannerSize)
        initializeAdLoader()
    }
    
//MARK: Interstitial
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: interstitialID)
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
    
    //MARK: Banner Ad
    func addBannerAdTo(view:UIView) {
        bannerView.backgroundColor = .gray
        bannerView.contentMode = .scaleToFill
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .centerY,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerY,
                                multiplier: 1,
                                constant: -30),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        bannerSetup()
    }
    
    func bannerSetup() {
        bannerView.adUnitID = bannerID
        bannerView.rootViewController = Router.rootVC()
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    //MARK: Native Ad
    
    func initializeAdLoader() {
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5
        adLoader = GADAdLoader(adUnitID: nativeAd,
                               rootViewController: Router.rootVC(),
                               adTypes: [GADAdLoaderAdType.unifiedNative],
                               options: [multipleAdsOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAd: GADUnifiedNativeAd) {
        print(nativeAd)
        // A unified native ad has loaded, and can be displayed.
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        // The adLoader has finished loading ads, and a new request can be sent.
        print(adLoader)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}
