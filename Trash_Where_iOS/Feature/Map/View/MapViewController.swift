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

final class MapViewController: UIViewController {

  // MARK: - Properties
  
  var mapView: MKMapView!
  var locationManager = CLLocationManager()
  var directions = [String]()
  
  // MARK: - UI
  
  var userLocationButton: UIButton = {
    // TODO: 버튼 클릭시 색상변경
    let button = UIButton()
    let userLocationImageView = UIImageView(image: UIImage(named: "GPSemoji"))
    button.backgroundColor = .white
    button.layer.cornerRadius = 20
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 2)
    button.layer.shadowOpacity = 0.5
    button.layer.shadowRadius = 3
    button.addSubview(userLocationImageView)
    userLocationImageView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(8)
    }
    return button
  }()
  lazy var bottomSheetView: BottomSheetView = {
    let bottomSheetView = BottomSheetView()
    bottomSheetView.bottomSheetColor = .lightGray
    bottomSheetView.barViewColor = .darkGray
    bottomSheetView.mapView = self.mapView
    return bottomSheetView
  }()
  
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView = MKMapView(frame: view.frame)
    setupCLLocationManager()
    setupMapView()
    addTarget()
    
    configureSubviews()
    
    // TODO: 서버 API와 연결
    addTrashAnnotation()
  }
  
  func addTrashAnnotation() {
    // Sample Data
    let coordinate = [
      (36.3167, 127.4435), (36.3178, 127.4419),
      (36.3167, 127.4400), (36.3141, 127.4455),
      (36.3198, 127.4482)]
    
    _=coordinate.map {
      mapView.addAnnotation(TrashAnnotation(imageType: 0, coordinate: CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1)))
    }
  }
  
  func addTarget() {
    userLocationButton.addTarget(self, action: #selector(setMapRegion), for: .touchUpInside)
  }
  
// MARK: - Action
  
  @objc func setMapRegion() {
    var coordiCenterLa = mapView.userLocation.coordinate.latitude
    let coordiCenterLo = mapView.userLocation.coordinate.longitude
    coordiCenterLa -= 0.001
    
    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordiCenterLa, longitude: coordiCenterLo),
                                    latitudinalMeters: 450, longitudinalMeters: 450)
    mapView.setRegion(region, animated: true)
    bottomSheetView.mode = .tip
    
    mapView.removeMapViewOverlayOfLast()
  }
  
  // MARK: - Method
  
  func calculateDirections(coordinate: CLLocationCoordinate2D) {
    let destinationPlacemark = MKPlacemark(coordinate: coordinate)
    // 사용자의 현재 위치
    let startMapItem = MKMapItem.forCurrentLocation()
    // 도착 위치
    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
    
    let request = MKDirections.Request()
    request.transportType = .walking
    request.source = startMapItem
    request.destination = destinationMapItem
    
    let direction = MKDirections(request: request)
    direction.calculate { [weak self] response, error in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      
      //rotue.first에는 경로의 경우의 수 중 가장 빠른 경로를 가지고 있음
      guard let response = response, let route = response.routes.first else {
        return
      }
      
      if !route.steps.isEmpty {
        for step in route.steps {
          print(step.instructions)
          
          self?.directions.append(step.instructions)
        }
      }
      
      self?.mapView.addOverlay(route.polyline, level: .aboveRoads)
    }
  }
  
}


//MARK: - Method

extension MKMapView {
  
  public func removeMapViewOverlayOfLast() {
    if !overlays.isEmpty {
      removeOverlay(overlays.last!)
    }
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
  
  // annotation 클릭시 이 함수 호출
  func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
    if annotation is MKUserLocation {
      return
    }
    
    mapView.removeMapViewOverlayOfLast()
    self.bottomSheetView.cancelPinButton.isHidden = false
    self.bottomSheetView.popUpBottomSheet()
    
    var coordiCenterLa = annotation.coordinate.latitude
    let coordiCenterLo = annotation.coordinate.longitude
    coordiCenterLa -= 0.002
    
    let coordinate = CLLocationCoordinate2D(latitude: coordiCenterLa, longitude: coordiCenterLo)
    let region = MKCoordinateRegion(center: coordinate,
                                    latitudinalMeters: 450, longitudinalMeters: 450)
    mapView.setRegion(region, animated: true)
    calculateDirections(coordinate: annotation.coordinate)
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.lineWidth = 5.0
      polylineRenderer.strokeColor = .blue
      return polylineRenderer
    }
    
    return MKOverlayRenderer()
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
    
    var coordiCenterLa = location.coordinate.latitude
    coordiCenterLa -= 0.001
    let coordiCenterLo = location.coordinate.longitude
    
    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordiCenterLa, longitude: coordiCenterLo),
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
    setupSubviewsConstraints()
  }
  
  func addSubviews() {
    self.view.addSubview(mapView)
    self.view.addSubview(self.bottomSheetView)
    mapView.addSubview(userLocationButton)
  }

}

extension MapViewController: SetupSubviewsConstraints {
  
  func setupSubviewsConstraints() {
    userLocationButton.snp.makeConstraints {
      $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(17)
      $0.bottom.equalTo(bottomSheetView.bottomSheetView.snp.top).inset(-25)
      $0.height.width.equalTo(40)
    }
    
    bottomSheetView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
  }
  
}