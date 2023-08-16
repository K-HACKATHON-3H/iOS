//
//  QRCodeViewController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/13.
//

import UIKit

class QRCodeViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
  }
  
  // MARK: - Method
  
  public func presentRewardVC() {
    let rewardVC = RewardViewController()
    self.present(rewardVC, animated: true)
  }
  
}
