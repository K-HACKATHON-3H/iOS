//
//  TabBarController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/13.
//

import UIKit

class TabBarController: UITabBarController {
  
  // MARK: - Properties
  
  let mapViewController = MapViewController()
  let qrcodeViewController = QRCodeViewController()
  let profileViewController = UINavigationController(rootViewController: ProfileViewController())
  
  // UI
  var customOrangeColor: UIColor = UIColor(cgColor: CGColor(red: 243/255, green: 166/255, blue: 88/255, alpha: 1))
//  lazy var naviSlideBar: UIView = {
//    let view = UIView()
//    view.backgroundColor = customOrangeColor
////    view.bounds.size.height = 20
////    view.bounds.size.width = 30 // TabBarItem이 바뀌면서 width가 변화
//  //  view.frame = CGRect(x: (self.tabBar.bounds.width - 100) / 2, y: -20, width: 100, height: 50) // 위치와 크기를 조절
//
//    self.tabBar.addSubview(view)
//    self.tabBar.bringSubviewToFront(view)
//    self.tabBar.clipsToBounds = false
//    
//    view.snp.makeConstraints {
//      $0.top.equalToSuperview()
//      $0.leading.equalToSuperview()
//      $0.height.equalTo(5)
//      $0.width.equalTo(20)
//    }
//    return view
//  }()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setTabBarItem()
    setTabBarColor()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    setTabBarLayout()
  }
  
  // MARK: - Methode
  
  private func setTabBarItem() {
    mapViewController.tabBarItem =
    UITabBarItem(title: nil, image: UIImage(named: "TabBarItemHome"), tag: 0)
    qrcodeViewController.tabBarItem =
    UITabBarItem(title: nil, image: UIImage(named: "TabBarItemBadge"), tag: 1)
    profileViewController.tabBarItem =
    UITabBarItem(title: nil, image: UIImage(named: "TabBarItemProfile"), tag: 2)
    
    mapViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
    qrcodeViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
    profileViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
    
    
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
