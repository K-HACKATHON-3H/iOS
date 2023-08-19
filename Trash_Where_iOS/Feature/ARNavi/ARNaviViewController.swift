//
//  ARNaviViewController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/31.
//

import ARKit_CoreLocation
import ARKit
import CoreLocation
import SceneKit
import SnapKit
import UIKit

class ARNaviViewController: UIViewController {
  
  // MARK: - Properties
  
  var arPinModel: PinModel!
  var currentCoinModel: PinModel!
  let locationManager = CLLocationManager()
  var pinElevationAPI = PinElevationAPI()
  var coinLocations = [CLLocationCoordinate2D]()
  var coinIndex = 0
  
  // MARK: - UI
  
  let sceneLocationView = SceneLocationView()
  lazy var dismissButton: UIButton = {
    let button = UIButton()
    button.setTitle("Dismiss", for: .normal)
    button.backgroundColor = .black
    button.layer.cornerRadius = 5
    button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    return button
  }()
  let statusView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    return view
  }()
  lazy var statusLabel: UILabel = {
    let label = UILabel()
    label.text = arPinModel.address
    label.font = UIFont.systemFont(ofSize: 22)
    return label
  }()
  let distanceLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 15)
    label.textColor = .lightGray
    return label
  }()
  
  // AR UI
  var pinLocationNode: LocationNode!
  var pinNode: SCNNode = {
    let pinScene = SCNScene(named: "SceneKit_Assets.scnassets/Pointers.scn")!
    let pinNode = pinScene.rootNode.childNode(withName: "C3_002", recursively: true)
    pinNode!.scale = SCNVector3(x: 25, y: 25, z: 25)
    pinNode!.position = SCNVector3(x: 0, y: 2, z: 0) // *
    
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.red
    material.specular.contents = UIColor.white
    material.shininess = 50.0
    
    let light = SCNLight()
    light.type = .IES
    light.intensity = 2000

    let lightFrontNode = SCNNode()
    lightFrontNode.light = light
    lightFrontNode.position = SCNVector3(x: -100, y: 100, z: -100)
    lightFrontNode.castsShadow = true
    
    let lightBackNode = SCNNode()
    lightBackNode.light = light
    lightBackNode.position = SCNVector3(x: 100, y: 100, z: 100)
    lightBackNode.castsShadow = true

    pinNode?.addChildNode(lightFrontNode)
    pinNode?.addChildNode(lightBackNode)
    pinNode?.geometry?.materials = [material]
    return pinNode!
  }()
  var coinLocationNode: LocationNode!
  var coinNode: SCNNode = {
    let pointScene = SCNScene(named: "SceneKit_Assets.scnassets/coinclover.scn")!
    let coinNode = pointScene.rootNode.childNode(withName: "coin", recursively: true)
    coinNode?.scale = SCNVector3(20, 20, 20)
    coinNode?.position = SCNVector3(x: 0, y: 0.5, z: 0)
    
    let light = SCNLight()
    light.type = .IES
    light.intensity = 3000

    let lightFrontNode = SCNNode()
    lightFrontNode.light = light
    lightFrontNode.position = SCNVector3(x: -100, y: 100, z: -100)
    lightFrontNode.castsShadow = true
    
    let lightBackNode = SCNNode()
    lightBackNode.light = light
    lightBackNode.position = SCNVector3(x: 100, y: 100, z: 100)
    lightBackNode.castsShadow = true
    
    //animation
    let rotateAction = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 5)
    let repeatRotateAction = SCNAction.repeatForever(rotateAction)
    
    let moveUp = SCNAction.moveBy(x: 0, y: 1, z: 0, duration: 1)
    let moveDown = SCNAction.moveBy(x: 0, y: -1, z: 0, duration: 1)
    let repeatUpDownAction = SCNAction.repeatForever(SCNAction.sequence([moveUp, moveDown]))
    
    coinNode?.addChildNode(lightFrontNode)
    coinNode?.addChildNode(lightBackNode)
    coinNode?.runAction(repeatRotateAction)
    coinNode?.runAction(repeatUpDownAction)
    return coinNode!
  }()
  var spotNode: SCNNode = {
    let node = SCNNode()
    let cylinderGeometry = SCNCylinder(radius: 15, height: 0.5)
    let transparentMaterial = SCNMaterial()
    transparentMaterial.diffuse.contents = UIColor.green
    transparentMaterial.transparency = 0.5
    cylinderGeometry.materials = [transparentMaterial]
    node.geometry = cylinderGeometry
    
    return node
  }()
  
  //MARK: - LifeCycle

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    
    sceneLocationView.debugOptions = [.showFeaturePoints]
    sceneLocationView.autoenablesDefaultLighting = true
    
    setLocationManager()
    addSCNNode()
    configureSubviews()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    locationManager.stopUpdatingLocation()
    sceneLocationView.pause()
  }
  
  // MARK: - Method
  
  func addSCNNode() {
    // pinNode
    let targetCoordinate = CLLocationCoordinate2D(
      latitude: arPinModel.latitude, longitude: arPinModel.longitude)
    let pinLocation = CLLocation(coordinate: targetCoordinate, altitude: 60)
    pinLocationNode = LocationNode(location: pinLocation)
    pinLocationNode.addChildNode(pinNode)
    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
    
    if !coinLocations.isEmpty {
      spotNode.addChildNode(coinNode)
      let guidPointLocation = CLLocation(coordinate: coinLocations[0], altitude: 60)
      coinLocationNode = LocationNode(location: guidPointLocation)
      coinLocationNode!.addChildNode(spotNode)
      sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: coinLocationNode!)
    }
    
    sceneLocationView.run()
  }
  
  func setLocationManager() {
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
    locationManager.requestWhenInUseAuthorization()
  }
  
  // MARK: - Action
  
  @objc func dismissButtonTapped() {
    self.presentingViewController?.dismiss(animated: true)
  }
  
}

// MARK: - PinElevationAPIDelegate

extension ARNaviViewController: PinElevationAPIDelegate {
  
  func didUpdateElevation(_ pinElevationAPI: PinElevationAPI, pinModel: [PinModel], type: RequestType) {
    DispatchQueue.main.async {
      if type == .pinNode {
        _=pinModel.map {
          if $0.pinID == self.arPinModel.pinID {
            let updateAltitude: CLLocationDistance = $0.elevation
            if let currentLocation = self.pinLocationNode.location {
              let newLocation = CLLocation(coordinate: currentLocation.coordinate, altitude: updateAltitude)
              self.pinLocationNode.location = newLocation
            }
          }
        }
      } else if type == .coinNode {
        _=pinModel.map {
          if $0.pinID == self.currentCoinModel.pinID {
            let updateAltitude: CLLocationDistance = $0.elevation
            if let currentLocation = self.coinLocationNode!.location {
              let newLocation = CLLocation(coordinate: currentLocation.coordinate, altitude: updateAltitude)
              self.coinLocationNode!.location = newLocation
            }
          }
        }
      }
      
      print("didUpdateElevation!")
    }
  }
  
  func didFailWithError(error: Error) {
    print(error)
  }
  
}

// MARK: - CLLocationManagerDelegate

extension ARNaviViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let currentLocation = locations.last else { return }
    
    let distanceInPinNodeOfMeters = currentLocation.distance(from: CLLocation(latitude: arPinModel.latitude, longitude: arPinModel.longitude))
    distanceLabel.text = "\(Int(distanceInPinNodeOfMeters))m"
    
    if distanceInPinNodeOfMeters <= 15 { // 쓰레기통 도착!
      // 리워드 지급 페이지
      if let tabVC = self.presentingViewController as? UITabBarController {
        if let mapVC = tabVC.selectedViewController as? MapViewController {
          mapVC.presentRewardPage()
        }
      }
    }
    
    guard !coinLocations.isEmpty else { return }
    guard coinLocationNode != nil else { return }
    
    if coinIndex < coinLocations.count {
      
      let coinLatitude = coinLocations[coinIndex].latitude
      let coinLongitude = coinLocations[coinIndex].longitude
      let distanceInCoinNodeOfMeters = currentLocation.distance(from: CLLocation(latitude: coinLatitude, longitude: coinLongitude))
      
      if distanceInCoinNodeOfMeters < 25 { // 코인 획득!!
        coinIndex += 1
        // TODO: Point 리워드 지급
        
        if coinIndex < coinLocations.count {
          coinLocationNode!.location = CLLocation(coordinate: coinLocations[coinIndex], altitude: coinLocationNode!.location.altitude)
          
          // coinNode Elevation API Fetch
          pinElevationAPI.fetchElevation(pinModel: PinModel(latitude: coinLocations[coinIndex].latitude, longitude: coinLocations[coinIndex].longitude), type: .coinNode)
          
        } else {
          // 마지막 node이니 더이상 node를 추가할 필요가 없음
          sceneLocationView.removeLocationNode(locationNode: coinLocationNode!)
        }
      }
    }
  }
  
}
  
  // MARK: - LayoutSupport
  
extension ARNaviViewController: LayoutSupport {
  
  func configureSubviews() {
    addSubviews()
    setupSubviewsConstraints()
  }
  
  func addSubviews() {
    self.view.addSubview(sceneLocationView)
    self.sceneLocationView.addSubview(dismissButton)
    sceneLocationView.addSubview(statusView)
    
    statusView.addSubview(statusLabel)
    statusView.addSubview(distanceLabel)
  }
  
  func setupSubviewsConstraints() {
    sceneLocationView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    dismissButton.snp.makeConstraints {
      $0.top.trailing.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    statusView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(120)
    }
    
    statusLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(15)
      $0.leading.equalToSuperview().offset(10)
    }
    
    distanceLabel.snp.makeConstraints {
      $0.top.equalTo(statusLabel).offset(30)
      $0.leading.equalToSuperview().offset(10)
    }
  }
  
}
