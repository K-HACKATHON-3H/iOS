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
  let bottomSheetView: BottomSheetView = {
    let bottomSheetView = BottomSheetView()
    bottomSheetView.bottomSheetColor = .lightGray
    bottomSheetView.barViewColor = .darkGray
    return bottomSheetView
  }()
  
  // Feature Properties
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView = MKMapView(frame: view.frame)
    
    configureSubviews()
    self.view.clipsToBounds = true
    
    // TODO: 서버 API와 연결
    addTrashAnnotation(imageType: 0, coordinate: CLLocationCoordinate2D(latitude: 36.3167, longitude: 127.4435))
  }
  
  func addTrashAnnotation(imageType: Int, coordinate: CLLocationCoordinate2D) {
    let annotation = TrashAnnotation(imageType: imageType, coordinate: coordinate)
    mapView.addAnnotation(annotation)
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
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    // 사용자 현재위치의 view setting
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
    
    guard let annotation = annotation as? TrashAnnotation else {
      return nil
    }
    
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier:
                                                                TrashAnnotationView.identifier)
    
    if annotationView == nil {
      annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier:
                                          TrashAnnotationView.identifier)
      annotationView?.canShowCallout = false
      annotationView?.contentMode = .scaleAspectFit
    } else {
      annotationView?.annotation = annotation
    }
    
    let annotationImage: UIImage!
    let size = CGSize(width: 65, height: 69)
    UIGraphicsBeginImageContext(size)
    
    // TODO: 추가되는 서비스를 대비한 logic
    switch annotation.imageType {
    case 0:
      annotationImage = UIImage(named: "TestPin")
    default:
      annotationImage = UIImage(systemName: "trash.circle")
    }
    annotationImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    annotationView?.image = resizedImage
    
    return annotationView
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    // TODO: Trash에 대한 상세 정보
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
    mapView.setRegion(region, animated: false)
    
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
    
    self.view.addSubview(self.bottomSheetView)
    
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
      $0.bottom.equalTo(bottomSheetView.bottomSheetView.snp.top).inset(-25)
      $0.height.width.equalTo(40)
      //$0.width.equalTo(40)
    }
    
    userLocationButtonImageView.snp.makeConstraints {
      $0.top.equalTo(userLocationButton.snp.top).offset(8)
      $0.leading.equalTo(userLocationButton.snp.leading).offset(8)
      $0.trailing.equalTo(userLocationButton.snp.trailing).inset(8)
      $0.bottom.equalTo(userLocationButton.snp.bottom).inset(8)
    }
    
    bottomSheetView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
}
