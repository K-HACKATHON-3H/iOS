//
//  TrashDetailViewController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/20.
//

import CoreLocation
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
    static let cornerRadius = 37.0
    static let barViewTopSpacing = 5.0
    static let barViewSize = CGSize(width: UIScreen.main.bounds.width * 0.1, height: 5.0)
    static let bottomSheetRatio: (Mode) -> Double = { mode in
      switch mode {
      case .tip:
        return 0.77 // 값 작을수록 높이이 커짐)
      case .full:
        return 0.65
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
        mapView?.deselectAnnotation(mapView?.selectedAnnotations as? MKAnnotation, animated: true)
        mapView.removeMapViewOverlayOfLast()
        self.changeModeToTip()
        break
      case .full:
        self.changeModeToFull()
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
  var customOrangeColor: UIColor = UIColor(cgColor: CGColor(red: 243/255, green: 166/255, blue: 88/255, alpha: 1))
  var mapView: MKMapView!
  weak var delegate: BottomSheetViewDelegate?
  var selectedPinModel: PinModel?
  static let locationManager: CLLocationManager = {
    let locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
    locationManager.requestWhenInUseAuthorization()
    return locationManager
  }()
  var distanceOfMeters: Double = 0.0 {
    didSet {
      self.distanceLabel.text = "\(distanceOfMeters)"
    }
  }
  
  // MARK: - UI
  
  lazy var boundaryLineView: UIView = {
    let view = UIView()
    view.backgroundColor = customOrangeColor
    return view
  }()
  let bottomSheetView: UIView = {
    let view = UIView()
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
  
  // stateContainView
  let stateContainView: UIView = {
    let view = UIView()
    return view
  }()
  let rankTierLabel: UILabel = {
    let label = UILabel()
    label.text = "새싹단계"
    label.font = UIFont(name: "Inter-Bold", size: 15)
    label.textColor = .systemGray
    return label
  }()
  let userNickNameLabel: UILabel = {
    let label = UILabel()
    label.text = "이치훈"
    label.font = UIFont(name: "Inter-Bold", size: 25)
    label.textColor = .black
    return label
  }()
  let nameHonorLabel: UILabel = {
    let label = UILabel()
    label.text = "님"
    label.font = UIFont(name: "Inter-Bold", size: 15)
    label.textColor = .black
    return label
  }()
  let pointLabel: UILabel = {
    let label = UILabel()
    label.text = "2500"
    label.font = UIFont(name: "Inter-Bold", size: 18)
    label.textColor = .black
    return label
  }()
  let pointUnitLabel: UILabel = {
    let label = UILabel()
    label.text = "P"
    label.font = UIFont(name: "Inter-Bold", size: 18)
    label.textColor = .black
    return label
  }()
  
  // TrashDataContainView (Mode.full 상태일 때 이 UI적용)
  lazy var trashDataContainView: UIView = {
    let view = UIView()
    // TrashDataContainView의 Contraints를 미리 짜서 .full될 때 TrashDataContainView만
    // StateContainView와 갈아 끼우는 식으로 구현
    // AddSubView
    view.addSubview(self.distanceImageView)
    view.addSubview(self.distanceLabel)
    view.addSubview(self.distanceUnitLabel)
    view.addSubview(self.TrashNameLabel)
    view.addSubview(self.getPointLabel)
//    view.addSubview(self.boundaryLineView)
    
    // MakeConstraints
    self.distanceImageView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview().inset(27)
    }
    self.distanceLabel.snp.makeConstraints {
      $0.leading.equalTo(distanceImageView.snp.trailing).offset(5)
      $0.centerY.equalTo(distanceImageView.snp.centerY)
    }
    self.distanceUnitLabel.snp.makeConstraints {
      $0.leading.equalTo(distanceLabel.snp.trailing).offset(3)
      $0.centerY.equalTo(distanceImageView.snp.centerY)
    }
    self.TrashNameLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(27)
      $0.top.equalTo(distanceImageView.snp.bottom).offset(10)
    }
    self.getPointLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(22)
      $0.centerY.equalTo(TrashNameLabel.snp.centerY)
    }
    
    return view
  }()
  let distanceImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "DistanceLocation")
    imageView.tintColor = UIColor(cgColor: CGColor(red: 147, green: 145, blue: 145, alpha: 1))
    return imageView
  }()
  lazy var distanceLabel: UILabel = {
    let label = UILabel()
    label.text = "94"
    //"\(self.distanceOfMeters)"
    label.font = UIFont(name: "Inter-Bold", size: 15)
    label.textColor = .gray//UIColor(cgColor: CGColor(red: 147, green: 145, blue: 145, alpha: 1))
    return label
  }()
  let distanceUnitLabel: UILabel = {
    let label = UILabel()
    label.text = "M"
    label.font = UIFont(name: "Inter-Bold", size: 15)
    label.textColor = .gray//UIColor(cgColor: CGColor(red: 147, green: 145, blue: 145, alpha: 1))
    return label
  }()
  lazy var TrashNameLabel: UILabel = {
    let label = UILabel()
    
    // TODO: rxSwift로 주소가 안바뀌는 문제 해결하기
    label.text = selectedPinModel?.address ?? "쓰레기통 주소"
    label.font = UIFont(name: "Inter-Bold", size: 20)
    label.textColor = .black
    return label
  }()
//  let timeImageView: UIImageView = {
//    let imageView = UIImageView()
//    imageView.image = UIImage(named: "TrashRemainClock")
//    return imageView
//  }()
//  let remainTimeLabel: UILabel = {
//    let label = UILabel()
//    label.text = "1H : 19M"
//    return label
//  }()
  let getPointLabel: UILabel = {
    let label = UILabel()
    label.text = "+15 P"
    label.font = UIFont(name: "Inter-Bold", size: 18)
    label.textColor = .black
    return label
  }()
  
  // UserRankingContainView
  lazy var userRankinContainerView: UIView = {
    let view = UIView()
    
    return view
  }()
  let rankingTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "1위 정보"
    label.font = UIFont(name: "Inter-Bold", size: 14)
    label.textColor = .black
    return label
  }()
  let viewMoreButton: UIButton = {
    let button = UIButton()
    button.setTitle("더 보기  〉", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.font = UIFont(name: "Inter-Bold", size: 14)
    return button
  }()
  let rankingProfileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "sunghoSampleImage")
    return imageView
  }()
  let rankingNameLabel: UILabel = {
    let label = UILabel()
    label.text = "이치훈"
    label.font = UIFont(name: "Inter-Bold", size: 18)
    label.textColor = .black
    return label
  }()
  let userHasPointLabel: UILabel = {
    let label = UILabel()
    label.text = "56 P"
    label.font = UIFont(name: "Inter-Bold", size: 14)
    label.textColor = .black
    return label
  }()
  
  lazy var arButton: UIButton = {
    let button = UIButton()
    button.setTitle("AR 길찾기", for: .normal)
    button.titleLabel?.font = UIFont(name: "Inter-Bold", size: 16)
    button.backgroundColor = customOrangeColor
    button.layer.cornerRadius = 22
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 3)
    button.layer.shadowOpacity = 0.3
    button.addTarget(self, action: #selector(arButtonTapped), for: .touchUpInside)
    return button
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .clear
    
    self.bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    self.bottomSheetView.layer.cornerRadius = Const.cornerRadius
    self.bottomSheetView.layer.shadowColor = UIColor.black.cgColor
    self.bottomSheetView.layer.shadowOffset = CGSize(width: 0, height: 0.1)
    self.bottomSheetView.layer.shadowOpacity = 0.5
    
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
   // cancelPinButton.addTarget(self, action: #selector(cancelPin), for: .touchUpInside)
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
     // hiddenDetailView()
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
   // hiddenDetailView()
    self.pushDownBottomSheet()
   // cancelPinButton.isHidden = true
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
        // velocity를 이용하여 위로 스와이프인지, 아래로 스와이프인지 확인)
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
  
  private func changeModeToFull() {
    // TODO: Constraints Code 리팩토링 시급
    if !mapView.selectedAnnotations.isEmpty && selectedPinModel != nil {
      // TODO: - MKUserLocation인경우 Data를 못받아 올 수 있음
      // annotation을 선택한 상태
      self.stateContainView.removeFromSuperview()
      self.arButton.isHidden = false
      self.boundaryLineView.isHidden = false
      self.bottomSheetView.addSubview(self.trashDataContainView)
      self.trashDataContainView.snp.makeConstraints {
        $0.top.equalTo(self.handlerView.snp.bottom)
        $0.leading.trailing.equalToSuperview()
        $0.height.equalTo(73) // stateContainView의 height 상수값
      }
      self.rankingTitleLabel.text = "쓰레기통랭킹 1위"
      
      // 쓰레기통 랭킹
      self.userRankinContainerView.snp.makeConstraints {
        $0.top.equalTo(trashDataContainView.snp.bottom)
        $0.leading.trailing.equalToSuperview()
        $0.bottom.equalToSuperview().inset(95)
      }
      
      self.rankingTitleLabel.snp.makeConstraints {
        $0.top.equalToSuperview().inset(10)
        $0.leading.equalToSuperview().inset(27)
      }
      
      self.viewMoreButton.snp.makeConstraints {
        $0.trailing.equalToSuperview().inset(22)
        $0.centerY.equalTo(rankingTitleLabel.snp.centerY)
      }
      
      self.rankingProfileImageView.snp.makeConstraints {
        $0.top.equalTo(rankingTitleLabel.snp.bottom).offset(10)
        $0.leading.equalToSuperview().inset(27)
      }
      
      self.rankingNameLabel.snp.makeConstraints {
        $0.leading.equalTo(rankingProfileImageView.snp.trailing).offset(10)
        $0.centerY.equalTo(rankingProfileImageView.snp.centerY).offset(-12)
      }
      
      self.userHasPointLabel.snp.makeConstraints {
        $0.leading.equalTo(rankingProfileImageView.snp.trailing).offset(10)
        $0.centerY.equalTo(rankingProfileImageView.snp.centerY).offset(12)
      }
      
      self.boundaryLineView.snp.makeConstraints {
        $0.top.equalToSuperview()
        $0.centerX.equalToSuperview()
        $0.height.equalTo(1)
        $0.width.equalToSuperview().multipliedBy(0.9)
      }
      
      self.arButton.snp.makeConstraints {
        $0.trailing.equalToSuperview().inset(22)
        $0.centerY.equalTo(rankingProfileImageView.snp.centerY)
        $0.height.equalTo(45)
        $0.width.equalTo(116)
      }
      
    } else { // 친구랭킹
      self.trashDataContainView.removeFromSuperview()
      self.arButton.isHidden = true
      self.boundaryLineView.isHidden = false
      self.bottomSheetView.addSubview(self.stateContainView)
      self.stateContainView.snp.makeConstraints {
        $0.top.equalTo(handlerView.snp.bottom)
        $0.leading.trailing.equalToSuperview()
        $0.height.equalTo(73)
      }
      
      self.rankingTitleLabel.text = "친구랭킹 1위"
      self.userRankinContainerView.snp.makeConstraints {
        $0.top.equalTo(stateContainView.snp.bottom)
        $0.leading.trailing.equalToSuperview()
        $0.bottom.equalToSuperview().inset(95)
      }
      
      self.rankingTitleLabel.snp.makeConstraints {
        $0.top.equalToSuperview().inset(10)
        $0.leading.equalToSuperview().inset(27)
      }
      
      self.viewMoreButton.snp.makeConstraints {
        $0.trailing.equalToSuperview().inset(22)
        $0.centerY.equalTo(rankingTitleLabel.snp.centerY)
      }
      
      self.rankingProfileImageView.snp.makeConstraints {
        $0.top.equalTo(rankingTitleLabel.snp.bottom).offset(10)
        $0.leading.equalToSuperview().inset(27)
      }
      
      self.rankingNameLabel.snp.makeConstraints {
        $0.leading.equalTo(rankingProfileImageView.snp.trailing).offset(10)
        $0.centerY.equalTo(rankingProfileImageView.snp.centerY).offset(-12)
      }
      
      self.userHasPointLabel.snp.makeConstraints {
        $0.leading.equalTo(rankingProfileImageView.snp.trailing).offset(10)
        $0.centerY.equalTo(rankingProfileImageView.snp.centerY).offset(12)
      }
      
      self.boundaryLineView.snp.makeConstraints {
        $0.top.equalToSuperview()
        $0.centerX.equalToSuperview()
        $0.height.equalTo(1)
        $0.width.equalToSuperview().multipliedBy(0.9)
      }
    }
  }
  
  private func changeModeToTip() {
    self.trashDataContainView.removeFromSuperview()
    self.boundaryLineView.isHidden = true
    self.bottomSheetView.addSubview(self.stateContainView)
    self.stateContainView.snp.makeConstraints {
      $0.top.equalTo(handlerView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(103)
    }
  }
  
}

// MARK: - CLLocationManagerDelegate

extension BottomSheetView: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let currentLocation = locations.last else { return }
    
    if selectedPinModel != nil {
      distanceOfMeters = currentLocation.distance(from: CLLocation(latitude: selectedPinModel!.latitude, longitude: selectedPinModel!.longitude))
    }
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
    self.bottomSheetView.addSubview(handlerView)
    
    self.bottomSheetView.addSubview(stateContainView)
    self.stateContainView.addSubview(rankTierLabel)
    self.stateContainView.addSubview(userNickNameLabel)
    self.stateContainView.addSubview(nameHonorLabel)
    self.stateContainView.addSubview(pointUnitLabel)
    self.stateContainView.addSubview(pointLabel)
    
    self.bottomSheetView.addSubview(userRankinContainerView)
    self.userRankinContainerView.addSubview(rankingTitleLabel)
    self.userRankinContainerView.addSubview(viewMoreButton)
    self.userRankinContainerView.addSubview(rankingProfileImageView)
    self.userRankinContainerView.addSubview(rankingNameLabel)
    self.userRankinContainerView.addSubview(userHasPointLabel)
    self.userRankinContainerView.addSubview(boundaryLineView)
    self.userRankinContainerView.addSubview(arButton)
    
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
      $0.height.equalTo(25)
    }
    
    self.stateContainView.snp.makeConstraints {
      $0.top.equalTo(self.handlerView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(103)
    }
 
    self.rankTierLabel.snp.makeConstraints {
      $0.top.equalToSuperview()//.inset(22)
      $0.leading.equalToSuperview().inset(27)
    }
    
    self.userNickNameLabel.snp.makeConstraints {
      $0.top.equalTo(rankTierLabel.snp.bottom).offset(5)
      $0.leading.equalToSuperview().inset(25)
    }
    
    self.nameHonorLabel.snp.makeConstraints {
      $0.leading.equalTo(userNickNameLabel.snp.trailing).offset(4)
      $0.centerY.equalTo(userNickNameLabel.snp.centerY).offset(3)
    }
    
    self.pointUnitLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(22)
      $0.centerY.equalTo(userNickNameLabel.snp.centerY)
    }
    
    self.pointLabel.snp.makeConstraints {
      $0.trailing.equalTo(pointUnitLabel.snp.leading).offset(-3)
      $0.centerY.equalTo(userNickNameLabel.snp.centerY)
    }
    
    // UserRankingContainViewConstraints
    self.userRankinContainerView.snp.makeConstraints {
      $0.top.equalTo(stateContainView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().inset(95)
    }
    
    self.rankingTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(10)
      $0.leading.equalToSuperview().inset(27)
    }
    
    self.viewMoreButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(22)
      $0.centerY.equalTo(rankingTitleLabel.snp.centerY)
    }
    
    self.rankingProfileImageView.snp.makeConstraints {
      $0.top.equalTo(rankingTitleLabel.snp.bottom).offset(10)
      $0.leading.equalToSuperview().inset(27)
    }
    
    self.rankingNameLabel.snp.makeConstraints {
      $0.leading.equalTo(rankingProfileImageView.snp.trailing).offset(10)
      $0.centerY.equalTo(rankingProfileImageView.snp.centerY).offset(-12)
    }
    
    self.userHasPointLabel.snp.makeConstraints {
      $0.leading.equalTo(rankingProfileImageView.snp.trailing).offset(10)
      $0.centerY.equalTo(rankingProfileImageView.snp.centerY).offset(12)
    }
    
    self.boundaryLineView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.centerX.equalToSuperview()
      $0.height.equalTo(1)
      $0.width.equalToSuperview().multipliedBy(0.9)
    }
    
  }
}
