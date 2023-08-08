//
//  PinElevationModel.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/08/05.
//

import Foundation

//struct PinElevationData: Decodable {
//  let results: [Results]
//  let status: String
//}
//
//struct Results: Decodable {
//  let elevation: Double
//  let location: Location
//  let resolution: Double
//}

//struct Location: Decodable {
//  let lat: Double
//  let lng: Double
//}

struct PinElevationData: Decodable {
  let results: [Results]
}

struct Results: Decodable {
  let longitude: Double
  let elevation: Double
  let latitude: Double
}
