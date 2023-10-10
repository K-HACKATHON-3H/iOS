//
//  TabBarController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/13.
//

import UIKit

class TabBarController: UITabBarController {
  
  let mapViewController = MapViewController()
  let qrcodeViewController = QRCodeViewController()
  let profileViewController = UINavigationController(rootViewController: ProfileViewController())
  var customOrangeColor: UIColor = UIColor(cgColor: CGColor(red: 243/255, green: 166/255, blue: 88/255, alpha: 1))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setTabBarItem()
    setTabBarColor()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    setTabBarLayout()
  }
  
  private func setTabBarItem() {
    mapViewController.tabBarItem =
    UITabBarItem(title: nil, image: UIImage(named: "TabBarItemHome"), tag: 0)
    qrcodeViewController.tabBarItem =
    UITabBarItem(title: nil, image: UIImage(named: "TabBarItemBadge"), tag: 1)
    profileViewController.tabBarItem =
    UITabBarItem(title: nil, image: UIImage(systemName: "person"), tag: 2)
    
    self.viewControllers = [mapViewController, qrcodeViewController, profileViewController]
  }
  
}

// MARK: - TabBarSetting

extension TabBarController {
  
  // TabBar의 모양을 구성하는 func
  func setTabBarLayout() {
    var tabFrame = self.tabBar.frame
    tabFrame.size.height = 95
    tabFrame.origin.y = self.view.frame.size.height - 95
    self.tabBar.frame = tabFrame
    self.tabBar.tintColor = customOrangeColor
    
    self.tabBar.layer.shadowColor = UIColor.black.cgColor
    self.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0.1)
    self.tabBar.layer.shadowOpacity = 0.5
  }
  
  // TabBar의 Color를 구성하는 func
  func setTabBarColor() {
    if #available(iOS 15, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = UIColor.white
      UITabBar.appearance().standardAppearance = appearance
      UITabBar.appearance().scrollEdgeAppearance = appearance
    } else {
      UITabBar.appearance().barTintColor = UIColor.white
    }
  }
  
}
