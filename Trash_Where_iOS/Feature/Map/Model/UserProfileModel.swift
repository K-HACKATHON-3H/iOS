//
//  UserProfileModel.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/08/19.
//

import UIKit

struct UserProfileModel {
  var Image: UIImage = UIImage(systemName: "person.crop.circle")!
  var name: String
  var point: Int
  var topPercent: Float
  var todaysPoint: Int
  
  init(Image: UIImage, name: String, point: Int, topPercent: Float, todaypoint: Int) {
    self.Image = Image
    self.name = name
    self.point = point
    self.topPercent = topPercent
    self.todaysPoint = todaypoint
  }
  
}
