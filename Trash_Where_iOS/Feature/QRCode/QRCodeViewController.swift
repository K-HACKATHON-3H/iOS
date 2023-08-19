//
//  QRCodeViewController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/13.
//

import UIKit

class QRCodeViewController: UIViewController {
  
  let testLable: UILabel = {
    let label = UILabel()
    label.text = "대충 업적 보이는 화면"
    label.font = .boldSystemFont(ofSize: 35)
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    configureSubviews()
  }
  
  // MARK: - Method
  
  public func presentRewardVC() {
    let rewardVC = RewardViewController()
    self.present(rewardVC, animated: true)
  }
  
}

extension QRCodeViewController: LayoutSupport {
  
  func configureSubviews() {
    addSubviews()
    setupSubviewsConstraints()
  }
  
  func addSubviews() {
    self.view.addSubview(testLable)
  }
  
  func setupSubviewsConstraints() {
    self.testLable.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
    }
  }
  
}
