//
//  TrashAnnotation.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/20.
//

import MapKit
import UIKit

final class TrashAnnotationView: MKAnnotationView {
  
  static let identifier = "TrashAnnotationView"
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupUI() {
    frame = CGRect(x: 0, y: 0, width: 40, height: 50)
    //centerOffset = CGPoint(x: 0, y: 0)
    image = UIImage(named: "TestPin")
    backgroundColor = .clear
  }
  
}

class TrashAnnotation: NSObject, MKAnnotation {
  
  var pinModel: PinModel!
  let imageType: Int?
  var coordinate: CLLocationCoordinate2D
  
  init(pinModel: PinModel, imageType: Int?) {
    self.pinModel = pinModel
    self.imageType = imageType
    self.coordinate = CLLocationCoordinate2D(latitude: pinModel.latitude,
                                             longitude: pinModel.longitude)
    super.init()
  }
  
}
