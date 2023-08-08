//
//  TrashDetailViewController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/20.
//

import MapKit
import SnapKit
import UIKit

final class BottomSheetView: PassThroughView {
  
  // MARK: Constants
  enum Mode {
    case tip
    case full
  }
  
  private enum Const {
    static let duration = 0.5
    static let cornerRadius = 12.0
    static let barViewTopSpacing = 5.0
    static let barViewSize = CGSize(width: UIScreen.main.bounds.width * 0.2, height: 5.0)
    static let bottomSheetRatio: (Mode) -> Double = { mode in
      switch mode {
      case .tip:
        return 0.83 // 위에서 부터의 값 (밑으로 갈수록 값이 커짐)
      case .full:
        return 0.58
      }
    }
    static let bottomSheetYPosition: (Mode) -> Double = { mode in
      Self.bottomSheetRatio(mode) * UIScreen.main.bounds.height
    }
  }
  
  // MARK: - Properties
  
  var mode: Mode = .tip {
    didSet {
      switch self.mode {
      case .tip:
        cancelPinButton.isHidden = true
        mapView?.deselectAnnotation(mapView?.selectedAnnotations as? MKAnnotation, animated: true)
        mapView.removeMapViewOverlayOfLast()
        break
      case .full:
        cancelPinButton.isHidden = false
        showDetailView()
        break
      }
      self.updateConstraint(offset: Const.bottomSheetYPosition(self.mode))
    }
  }
  var bottomSheetColor: UIColor? {
    didSet { self.bottomSheetView.backgroundColor = self.bottomSheetColor }
  }
  var barViewColor: UIColor? {
    didSet { self.barView.backgroundColor = self.barViewColor }
  }
  var mapView: MKMapView!
  weak var delegate: BottomSheetViewDelegate?
  
  // MARK: - UI
  
  let bottomSheetView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGroupedBackground
    return view
  }()
  private let barView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.isUserInteractionEnabled = false
    view.layer.cornerRadius = 2.5
    return view
  }()
  let handlerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  let cancelPinButton: UIButton = {
    let button = UIButton()
    let cancelImageView = UIImageView(image: UIImage(systemName: "xmark"))
    button.backgroundColor = .white
    button.layer.cornerRadius = 15
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 2)
    button.layer.shadowOpacity = 0.5
    button.layer.shadowRadius = 3
    button.isHidden = true
    button.addSubview(cancelImageView)
    cancelImageView.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
    }
    cancelImageView.tintColor = .black
    return button
  }()
  let proFileView: UIView = {
    let view = UIView()
    view.backgroundColor = .darkGray
    view.layer.cornerRadius = 15
    return view
  }()
  let proFileImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle"))
    imageView.layer.cornerRadius = 30
    return imageView
  }()
  
  let pinDetailView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  lazy var arButton: UIButton = {
    let button = UIButton()
    button.setTitle("AR Button", for: .normal)
    button.backgroundColor = .black
    button.layer.cornerRadius = 5
    button.isHidden = true
    button.addTarget(self, action: #selector(arButtonTapped), for: .touchUpInside)
    return button
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .clear
   
    self.bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    self.bottomSheetView.layer.cornerRadius = Const.cornerRadius
    self.bottomSheetView.clipsToBounds = true
    
    addTarget()
    configureSubviews()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init() has not been implemented")
  }
  
  private func addTarget() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
    self.handlerView.addGestureRecognizer(panGesture)
    cancelPinButton.addTarget(self, action: #selector(cancelPin), for: .touchUpInside)
  }
  
  // MARK: - Action
  
  @objc private func didPan(_ recognizer: UIPanGestureRecognizer) {
    let translationY = recognizer.translation(in: self).y
    let minY = self.bottomSheetView.frame.minY
    let offset = translationY + minY
    
    if Const.bottomSheetYPosition(.full)...Const.bottomSheetYPosition(.tip) ~= offset {
      self.updateConstraint(offset: offset)
      recognizer.setTranslation(.zero, in: self)
    }
    UIView.animate(
      withDuration: 0,
      delay: 0,
      options: .curveEaseOut,
      animations: self.layoutIfNeeded,
      completion: nil
    )
    
    if recognizer.velocity(in: self).y >= 0 {
      hiddenDetailView()
    }
    
    guard recognizer.state == .ended else { return }
    UIView.animate(
      withDuration: Const.duration,
      delay: 0,
      options: .allowUserInteraction,
      animations: {
        // velocity를 이용하여 위로 스와이프인지, 아래로 스와이프인지 확인
        self.mode = recognizer.velocity(in: self).y >= 0 ? Mode.tip : .full
      },
      completion: nil
    )
  }
  
  @objc private func cancelPin() {
    hiddenDetailView()
    self.pushDownBottomSheet()
    cancelPinButton.isHidden = true
  }
  
  @objc private func arButtonTapped() {
    delegate?.didTapARButton()
  }
  
  // MARK: - Method
  
  public func popUpBottomSheet() { // bottomSheetView 올림
    UIView.animate(
      withDuration: Const.duration,
      delay: 0,
      options: .allowUserInteraction,
      animations: {
        // velocity를 이용하여 위로 스와이프인지, 아래로 스와이프인지 확인
        self.mode = .full
      },
      completion: nil
    )
  }
  
  public func pushDownBottomSheet() { //bottomSheetView 내림
    UIView.animate(
      withDuration: Const.duration,
      delay: 0,
      options: .allowUserInteraction,
      animations: {
        // velocity를 이용하여 위로 스와이프인지, 아래로 스와이프인지 확인
        self.mode = .tip
      },
      completion: nil
    )
  }
  
  private func showDetailView() {
    if !mapView.selectedAnnotations.isEmpty {
      arButton.isHidden = false
      pinDetailView.addSubview(arButton)
      arButton.snp.makeConstraints {
        $0.centerX.centerY.equalToSuperview()
        $0.height.equalTo(60)
        $0.width.equalTo(100)
      }
    } else {
      print("no selectPin")
    }
  }
  
  func hiddenDetailView() {
    arButton.removeFromSuperview()
  }
  
}

//MARK: - LayoutSupport

extension BottomSheetView: LayoutSupport {

  func configureSubviews() {
    addSubviews()
    setupSubviewsConstraints()
  }

  func addSubviews() {
    self.addSubview(self.bottomSheetView)
    self.bottomSheetView.addSubview(proFileView)
    self.bottomSheetView.addSubview(pinDetailView)
    self.bottomSheetView.addSubview(handlerView)
    
    self.proFileView.addSubview(proFileImageView)
    self.proFileView.addSubview(cancelPinButton)
    
    self.handlerView.addSubview(self.barView)
  }

}

extension BottomSheetView: SetupSubviewsConstraints {

  private func updateConstraint(offset: Double) {
    self.bottomSheetView.snp.updateConstraints {
      $0.left.right.bottom.equalToSuperview()
      $0.top.equalToSuperview().inset(offset)
    }
  }
  
  func setupSubviewsConstraints() {
    self.bottomSheetView.snp.makeConstraints {
      $0.left.right.bottom.equalToSuperview()
      $0.top.equalTo(Const.bottomSheetYPosition(.tip))
    }
    
    self.barView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(Const.barViewTopSpacing)
      $0.size.equalTo(Const.barViewSize)
    }
    
    self.handlerView.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(bottomSheetView)
      $0.height.equalTo(28)
    }
    
    self.cancelPinButton.snp.makeConstraints {
      $0.top.trailing.equalTo(proFileView).inset(8)
      $0.height.width.equalTo(30)
    }
    
    self.proFileView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview().inset(15)
      $0.height.equalTo(UIScreen.main.bounds.height / 9)
    }
    
    self.proFileImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(20)
      $0.height.width.equalTo(60)
    }
    
    self.pinDetailView.snp.makeConstraints {
      $0.top.equalTo(proFileView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
    }
  }

}
