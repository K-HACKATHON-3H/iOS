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
  
  @objc func setMapRegion() {
    let region = MKCoordinateRegion(center: mapView.userLocation.coordinate,
                                    latitudinalMeters: 450, longitudinalMeters: 450)
    mapView.setRegion(region, animated: true)
  }
  
// MARK: - UISetting
  
  // TODO: 버튼 클릭시 색상변경
  func setupUserLocationButton() {
    userLocationButton.backgroundColor = .white
    userLocationButton.layer.cornerRadius = 20
    userLocationButton.layer.shadowColor = UIColor.black.cgColor
    userLocationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
    userLocationButton.layer.shadowOpacity = 0.5
    userLocationButton.layer.shadowRadius = 3
    userLocationButton.addTarget(self, action: #selector(setMapRegion), for: .touchUpInside)
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
    let zoomLevel = log2(360 *
                         (Double(mapView.frame.size.width/256) /
                          mapView.region.span.longitudeDelta))
    
    if zoomLevel < 8 {
      let limitSpan = MKCoordinateSpan(latitudeDelta: 1.40625, longitudeDelta: 1.40625)
      let region = MKCoordinateRegion(center: center, span: limitSpan)
      mapView.setRegion(region, animated: true)
    }
  }
  
  // 사용자 현재위치의 view setting
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
      annotationView.image = UIImage(named: "userLocationIcon")
      annotationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.63)
      annotationView.layer.shadowColor = UIColor.systemBlue.cgColor
      annotationView.layer.shadowOffset = CGSize(width: 1, height: 1)
      annotationView.layer.shadowOpacity = 0.5
      annotationView.layer.shadowRadius = 5
      // ios 16 이상부터는 layer없이 바로 anchorpoint를 설정할 수 있음!
      return annotationView
    }
    return nil
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
    locationManager.startUpdatingHeading()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    
    let region = MKCoordinateRegion(center: location.coordinate,
                                    latitudinalMeters: 450, longitudinalMeters: 450)
    mapView.setRegion(region, animated: true)
    
    // 위치 업데이트 종료
    locationManager.stopUpdatingLocation()
  }
  
  // 사용자의 방향에따라 annotaion의 방향을 변경
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let rotationAngle = (newHeading.trueHeading * Double.pi) / 180.0
    if let annotationView = mapView.view(for: mapView.userLocation) {
      annotationView.transform = CGAffineTransform(rotationAngle: rotationAngle)
    }
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
