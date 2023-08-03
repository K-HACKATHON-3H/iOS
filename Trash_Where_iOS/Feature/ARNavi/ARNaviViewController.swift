//
//  ARNaviViewController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/31.
//

import ARKit
import AVFoundation
import RealityKit
import SceneKit
import SnapKit
import UIKit

class ARNaviViewController: UIViewController {
  
  // MARK: - UI
  
  let sceneView = ARSCNView()
  lazy var dismissButton: UIButton = {
    let button = UIButton()
    button.setTitle("Dismiss", for: .normal)
    button.backgroundColor = .black
    button.layer.cornerRadius = 5
    button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    return button
  }()
 
  //MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setSceneView()
    configureSubviews()
  }
  
  // MARK: - Method
  
  func setSceneView() {
    requestCameraAccess { [weak self] isHaveCameraAccess in
      if isHaveCameraAccess {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        configuration.worldAlignment = .gravity
        self?.sceneView.delegate = self
        self?.sceneView.showsStatistics = true
        self?.sceneView.automaticallyUpdatesLighting = true
        self?.sceneView.session.run(configuration)
        
//        let sphere = SCNSphere(radius: 0.2)
//        let material = SCNMaterial()
//        material.diffuse.contents = [material]
//
//        let node = SCNNode()
//        node.position = SCNVector3(0, 0.1, -0.5)
//        node.geometry = sphere
//
//        self?.sceneView.scene.rootNode.addChildNode(node)
          self?.sceneView.autoenablesDefaultLighting = true
        
        let diceScene = SCNScene(named: "SceneKit_Assets.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
          diceNode.position = SCNVector3(0, 0, -0.1)
          
          self?.sceneView.scene.rootNode.addChildNode(diceNode)
        }
        //let scene = SCNScene()
        
        //let pinNode = self?.createPinNode()
        //scene.rootNode.addChildNode(pinNode!)
        
        //self?.sceneView.scene = scene
      }
    }
  }
  
//  func createPinNode() -> SCNNode {
//    let pinHeight: CGFloat = 2
//    let pinBottomRadius: CGFloat = 0.3
//    let pinTopRadius: CGFloat = 0.8
//    let pinInset: CGFloat = 0.1
//
//    let pinPath = UIBezierPath()
//    pinPath.move(to: CGPoint(x: 0, y: 0))
//    pinPath.addLine(to: CGPoint(x: pinTopRadius, y: pinHeight - pinInset))
//    pinPath.addLine(to: CGPoint(x: pinBottomRadius, y: pinHeight))
//    pinPath.addLine(to: CGPoint(x: pinBottomRadius, y: pinInset))
//    pinPath.addLine(to: CGPoint(x: -pinBottomRadius, y: pinInset))
//    pinPath.addLine(to: CGPoint(x: -pinBottomRadius, y: pinHeight))
//    pinPath.addLine(to: CGPoint(x: -pinTopRadius, y: pinHeight - pinInset))
//    pinPath.close()
//
//    let pinShape = SCNShape(path: pinPath, extrusionDepth: pinInset)
//
//    let pinMaterial = SCNMaterial()
//    pinMaterial.diffuse.contents = UIColor.red
//
//    let pinNode = SCNNode(geometry: pinShape)
//    pinNode.geometry?.firstMaterial = pinMaterial
//
//    // 노드 위치 조정
//    pinNode.pivot = SCNMatrix4MakeTranslation(0, Float(pinHeight / 2), 0)
//    pinNode.position = SCNVector3(x: 0, y: 0, z: -0.5)
//
//    return pinNode
//  }
  
  func requestCameraAccess(_ completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized: // 사용자가 이전에 권한을 부여함
      completion(true)
    case .notDetermined: // 사용자가 아직 선택하지 않음
      AVCaptureDevice.requestAccess(for: .video) { response in
        completion(response)
      }
    default: // 거부 또는 제한된 상태
      completion(false)
    }
  }
  
  // MARK: - Action
  
  @objc func dismissButtonTapped() {
    self.presentingViewController?.dismiss(animated: true)
  }
  
}

extension ARNaviViewController: ARSCNViewDelegate {
  
  
  
}

// MARK: - LayoutSupport

extension ARNaviViewController: LayoutSupport {
  
  func configureSubviews() {
    addSubviews()
    setupSubviewsConstraints()
  }
  
  func addSubviews() {
    self.view.addSubview(sceneView)
    self.sceneView.addSubview(dismissButton)
  }
  
  func setupSubviewsConstraints() {
    sceneView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    dismissButton.snp.makeConstraints {
      $0.top.trailing.equalTo(self.view.safeAreaLayoutGuide)
    }
  
  }
  
}
