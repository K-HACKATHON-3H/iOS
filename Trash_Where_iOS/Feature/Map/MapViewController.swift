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
  var userLocationButton = UIButton()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView = MKMapView(frame: view.frame)
    
    configureSubviews()
  }

// MARK: - Action
  
  
  
// MARK: - UISetting
  
  func setupUserLocationButton() {
    userLocationButton.setImage(UIImage(named: "GPSemoji"), for: .normal)
    userLocationButton.backgroundColor = .white
    userLocationButton.layer.cornerRadius = 20
    userLocationButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    userLocationButton.layer.shadowColor = UIColor.black.cgColor
    userLocationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
    userLocationButton.layer.shadowOpacity = 0.5
    userLocationButton.layer.shadowRadius = 3
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
// TODO: 추후 CoreLocation Feature 나눠야됨

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
    
    mapView.addSubview(userLocationButton)
  }
  
  func setupLayouts() {
    setupSubviewsLayouts()
    setupSubviewsConstraints()
  }
  
}

extension MapViewController: SetupSubviewsLayouts {
  
  func setupSubviewsLayouts() {
    setupMapView()
    setupCLLocationManager()
    setupUserLocationButton()
  }
  
}

extension MapViewController: SetupSubviewsConstraints {

  func setupSubviewsConstraints() {
    userLocationButton.snp.makeConstraints {
      $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(17)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(35)
      $0.height.equalTo(40)
      $0.width.equalTo(40)
    }
  }

}
