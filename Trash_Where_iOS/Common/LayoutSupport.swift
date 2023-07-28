//
//  LayoutSupport.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/12.
//

import Foundation

///UIView type's default configure
protocol LayoutSupport {
  
  /// Combine setupview's all configuration
  func configureSubviews()
  
  /// Add view to view's subview
  func addSubviews()
  
  ///Use ConfigureUI.setupConstraints(detail:apply:)
  func setupSubviewsConstraints()
  
}

// 잘 안씀

protocol SetupSubviewsLayouts {
  
  ///Use ConfigureUI.setupLayout(detail:apply:)
  func setupSubviewsLayouts()
  
}

protocol SetupSubviewsConstraints {
  
  ///Use ConfigureUI.setupConstraints(detail:apply:)
  func setupSubviewsConstraints()
  
}
