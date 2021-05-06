//
//  BlockingScreen.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 29.4.21..
//

import UIKit

class BlockingScreen: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var isOkToBlock = true
}

extension BlockingScreen {
    static func start(vc: UIViewController? = nil) {
        
        self.stop()
        
        DispatchQueue.main.async {
            
            let blockingScr = BlockingScreen(frame: UIScreen.main.bounds)
            setActivityIndicator(onView: blockingScr)
            
            if let vc = vc {
                vc.view.addSubview(blockingScr)
            } else {
                UIApplication.keyWindow!.addSubview(blockingScr)
            }
        }
    }
    
    static func setActivityIndicator(onView view: UIView) {
        let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityView.color = .white
        activityView.center = view.center
        view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    static func stop() {
        DispatchQueue.main.async {
            if let nvc = UIApplication.shared.topMostViewController() as? UINavigationController {
                for vc in nvc.viewControllers {
                    for view in vc.view.subviews where view is BlockingScreen {
                        UIView.animate(withDuration: 0.6) {
                            view.alpha = 0
                        } completion: { (_) in
                            view.removeFromSuperview()
                        }
                    }
                }
            }
            
            if let keyWindow = UIApplication.keyWindow {
                for view in keyWindow.subviews where view is BlockingScreen {
                    view.removeFromSuperview()
                }
            }
        }
    }
}

extension UIApplication {
    static var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController? {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? nil
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return UIApplication.keyWindow?.rootViewController?.topMostViewController()
    }
}

