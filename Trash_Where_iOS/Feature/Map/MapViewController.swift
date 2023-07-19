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

class MapViewController: UIViewController{

  // MARK: - Properties
  
  // UI Properties
  var mapView: MKMapView!
  var locationManager = CLLocationManager()
  var userLocationButton = UIButton()
  let userLocationButtonImageView = UIImageView(image: UIImage(named: "GPSemoji"))
  
  // Feature Properties
  lazy var center = mapView.centerCoordinate
  lazy var span = mapView.region.span

  let maxLatitude: CLLocationDegrees = 42.0
  let minLatitude: CLLocationDegrees = 29.0
  let maxLongitude: CLLocationDegrees = 130.0
  let minLongitude: CLLocationDegrees = 125.0

  lazy var newCenter = center
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView = MKMapView(frame: view.frame)
    
    configureSubviews()
  }
  

// MARK: - Action
  
 
  
// MARK: - UISetting
  
  func setupUserLocationButton() {
    userLocationButton.backgroundColor = .white
    userLocationButton.layer.cornerRadius = 20
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
  
  // 척도 범위 설정
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    // scale of map
    let center = mapView.userLocation.coordinate
    let zoomLevel = log2(360 * ((Double(mapView.frame.size.width/256)) / mapView.region.span.longitudeDelta))
    
    if zoomLevel < 8 {
      let limitSpan = MKCoordinateSpan(latitudeDelta: 1.40625, longitudeDelta: 1.40625)
      let region = MKCoordinateRegion(center: center, span: limitSpan)
      mapView.setRegion(region, animated: true)
    }
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
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    
    let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
    mapView.setRegion(region, animated: true)
    
    // 위치 업데이트 종료
    locationManager.stopUpdatingLocation()
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
    
    userLocationButton.addSubview(userLocationButtonImageView)
  }
  
  func setupLayouts() {
    setupSubviewsLayouts()
    setupSubviewsConstraints()
  }
  
}

extension MapViewController: SetupSubviewsLayouts {
  
  func setupSubviewsLayouts() {
    setupCLLocationManager()
    setupMapView()
    
    // UISetup
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
    
    userLocationButtonImageView.snp.makeConstraints {
      $0.top.equalTo(userLocationButton.snp.top).offset(8)
      $0.leading.equalTo(userLocationButton.snp.leading).offset(8)
      $0.trailing.equalTo(userLocationButton.snp.trailing).inset(8)
      $0.bottom.equalTo(userLocationButton.snp.bottom).inset(8)
    }
  }

}
