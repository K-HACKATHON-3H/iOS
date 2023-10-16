//
//  RewordViewController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/08/15.
//

import SnapKit
import UIKit

class RewardViewController: UIViewController {
  
  // MARK: - UI
  
  var customOrangeColor: UIColor = UIColor(cgColor: CGColor(red: 243/255, green: 166/255, blue: 88/255, alpha: 1))
  lazy var topBackGroundView: UIView = {
    let view = UIView()
    view.backgroundColor = customOrangeColor
    view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    view.layer.cornerRadius = 10
    return view
  }()
  lazy var plusThreeLabel: UILabel = {
    let label = UILabel()
    label.text = "+ 3P"
    label.font = UIFont(name: "Inter-Bold", size: 60)
    label.textColor = customOrangeColor
    return label
  }()
  let congratulationsLabel: UILabel = {
    let label = UILabel()
    label.text = "축하합니다!"
    label.font = UIFont(name: "Inter-Bold", size: 20)
    label.textColor = .white
    return label
  }()
  let addPointImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "AddPoint")
    return imageView
  }()
  let trashAddressLabel: UILabel = {
    let label = UILabel()
    label.text = "대전 동구 천동 대전로 542번길"
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    configureSubviews()
  }
  
}

// MARK: - LayoutSupport

extension RewardViewController: LayoutSupport {
  
  func configureSubviews() {
    addSubviews()
    setupSubviewsConstraints()
  }
  
  func addSubviews() {
    self.view.addSubview(topBackGroundView)
    self.topBackGroundView.addSubview(addPointImageView)
    self.topBackGroundView.addSubview(congratulationsLabel)
    self.topBackGroundView.addSubview(trashAddressLabel)
    
    self.view.addSubview(plusThreeLabel)
  }
  
  func setupSubviewsConstraints() {
    
    self.topBackGroundView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalToSuperview().multipliedBy(0.65)
    }
    
    self.plusThreeLabel.snp.makeConstraints {
      $0.bottom.equalToSuperview().multipliedBy(0.85)
      $0.centerX.equalToSuperview()
    }
    
    self.addPointImageView.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(120)
      $0.centerX.equalToSuperview()
    }
    
    self.congratulationsLabel.snp.makeConstraints {
      $0.bottom.equalTo(addPointImageView.snp.top).inset(-25)
      $0.centerX.equalToSuperview()
    }
    
    self.trashAddressLabel.snp.makeConstraints {
      $0.top.equalTo(addPointImageView.snp.bottom).offset(25)
      $0.centerX.equalToSuperview()
    }
  }
  
}
