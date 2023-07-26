//
//  TrashAnnotation.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/20.
//

import MapKit
import UIKit

class TrashAnnotationView: MKAnnotationView {
  
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
  
  let imageType: Int?
  var coordinate: CLLocationCoordinate2D
  
  init(imageType: Int?,
                coordinate: CLLocationCoordinate2D) {
    self.imageType = imageType
    self.coordinate = coordinate
    super.init()
  }
  
}
