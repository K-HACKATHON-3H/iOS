//
//  PinModel.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/08/04.
//

import Foundation

class PinModel {
  
  var pinID: String
  var address = ""
  var latitude: Double = 0.0
  var longitude: Double = 0.0
  var elevation: Double = 60.0
  var distance: Int = 0
  var bestUser: UserProfileModel?
  
  init(address: String = "", latitude: Double, longitude: Double) {
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.pinID = "\(latitude)" + "\(longitude)"
  }
  
  func setDistance(_ dis: Int) {
    self.distance = dis
  }
  
}
