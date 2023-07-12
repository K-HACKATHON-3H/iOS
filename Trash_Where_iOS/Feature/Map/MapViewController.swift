//
//  ViewController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/12.
//

import CoreLocation
import MapKit
import RxSwift
import SnapKit
import UIKit

class MapViewController: UIViewController {

  // MARK: - Properties
  
  var mapView: MKMapView!
  var locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView = MKMapView(frame: view.frame)
    
    configureSubviews()
  }


}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
  
  // MKMapView에 대한 초기 설정
  func setupMapView() {
    mapView.delegate = self
    mapView.showsUserLocation = true // 사용자 위치
  }
  
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
    
    mapView.setRegion(region, animated: true)
  }
  
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
  
  // CLLocation에 대한 초기 설정
  func setupCLLocationManager() {
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.startUpdatingLocation()
  }
  
}

// MARK: - LayoutSupport Protocol

extension MapViewController: LayoutSupport {
  func configureSubviews() {
    addSubviews()
    setupLayouts()
  }
  
  func addSubviews() {
    self.view.addSubview(mapView)
  }
  
  func setupLayouts() {
    setupSubviewsLayouts()
    //setupSubviewsConstraints()
  }
  
}

extension MapViewController: SetupSubviewsLayouts {
  
  func setupSubviewsLayouts() {
    setupMapView()
    setupCLLocationManager()
  }
  
}

//extension MapViewController: SetupSubviewsConstraints {
//
//  func setupSubviewsConstraints() {
//    <#code#>
//  }
//
//}
