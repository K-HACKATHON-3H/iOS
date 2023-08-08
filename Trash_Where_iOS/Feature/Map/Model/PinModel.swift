//
//  PinModel.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/08/04.
//

import Foundation

struct PinModel {
  
  var pinID: String
  var address = ""
  var latitude: Double = 0.0
  var longitude: Double = 0.0
  var elevation: Double = 300.0
  
  init(address: String = "", latitude: Double, longitude: Double) {
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.pinID = "\(latitude)" + "\(longitude)"
  }
  
}
