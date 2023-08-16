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
  
  var testLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.text = "리워드 보상 화면"
    let font = UIFont.systemFont(ofSize: 35)
    let fontDescriptor = font.fontDescriptor
    label.font = UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitBold)!, size: 35)
    
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white   
    
    configureSubviews()
  }
  
}

extension RewardViewController: LayoutSupport {
  
  func configureSubviews() {
    addSubviews()
    setupSubviewsConstraints()
  }
  
  func addSubviews() {
    self.view.addSubview(testLabel)
  }
  
  func setupSubviewsConstraints() {
    testLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
}
