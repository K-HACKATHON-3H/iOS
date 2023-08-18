//
//  TabBarController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/13.
//

import UIKit

class TabBarController: UITabBarController {
  
  let mapViewController = MapViewController()
  let distanceRankingViewController = UINavigationController(rootViewController:  DistanceRankingViewController())
  let qrcodeViewController = QRCodeViewController()
  let alertViewController = UINavigationController(rootViewController: AlertViewController())
  let profileViewController = UINavigationController(rootViewController: ProfileViewController())
  
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
    UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
//    distanceRankingViewController.tabBarItem =
//    UITabBarItem(title: "거리순", image: UIImage(systemName: "arrow.up.arrow.down"), tag: 1)
    qrcodeViewController.tabBarItem =
    UITabBarItem(title: "QR코드", image: UIImage(systemName: "qrcode"), tag: 2)
//    alertViewController.tabBarItem =
//    UITabBarItem(title: "알림", image: UIImage(systemName: "bell"), tag: 3)
    profileViewController.tabBarItem =
    UITabBarItem(title: "MY", image: UIImage(systemName: "person"), tag: 4)
    
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
    
    self.tabBar.tintColor = .black
    self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    self.tabBar.layer.cornerRadius = 15.0
    self.tabBar.layer.masksToBounds = true
    self.tabBar.layer.borderColor = UIColor.black.cgColor
    self.tabBar.layer.borderWidth = 0.4
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
