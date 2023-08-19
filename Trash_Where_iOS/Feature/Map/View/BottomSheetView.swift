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
    static let cornerRadius = 15.0
    static let barViewTopSpacing = 5.0
    static let barViewSize = CGSize(width: UIScreen.main.bounds.width * 0.2, height: 5.0)
    static let bottomSheetRatio: (Mode) -> Double = { mode in
      switch mode {
      case .tip:
        return 0.741 // 위에서 부터의 값 (밑으로 갈수록 값이 커짐) (0.83)
      case .full:
        return 0.55
      }
    }
    static let bottomSheetYPosition: (Mode) -> Double = { mode in
      Self.bottomSheetRatio(mode) * UIScreen.main.bounds.height
    }
  }
  
  // MARK: - Properties
  
  // test USerProperties
  let userProfileModel = UserProfileModel(Image: UIImage(named: "profileImage1")!, name: "iOS개발자 이치훈", point: 2500, topPercent: 34.61, todaypoint: 1)
  
  
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
  var trashDistance: Int = 197
  
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
  
  // proFileView
  let proFileView: UIView = {
    let view = UIView()
    view.backgroundColor = .darkGray
    view.layer.cornerRadius = 15
    return view
  }()
  lazy var proFileImageView: UIImageView = {
    let imageView = UIImageView(image: userProfileModel.Image)
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 30
    return imageView
  }()
  lazy var profileNameLabel: UILabel = {
    let label = UILabel()
    label.text = userProfileModel.name
    label.font = UIFont.boldSystemFont(ofSize: 20)
    label.textColor = .white
    return label
  }()
//  let todaysPointView: UIView = {
//    let view = UIView()
//    view.layer.borderColor = UIColor.white.cgColor
//    view.layer.borderWidth = 2
//    view.layer.cornerRadius = 5
//    return view
//  }()
  let profilePointLabel: UILabel = {
    let label = UILabel()
    label.text = "2500P"
    label.textColor = .white
    label.font = .boldSystemFont(ofSize: 15)
    return label
  }()
  
  // pinDetailView
  let pinDetailContainView: UIView = {
    let view = UIView()
    return view
  }()
  let pinDetailView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  lazy var arButton: UIButton = {
    let button = UIButton()
    button.setTitle("AR 길찾기", for: .normal)
    button.backgroundColor = .black
    button.layer.cornerRadius = 5
    button.isHidden = true
    button.addTarget(self, action: #selector(arButtonTapped), for: .touchUpInside)
    return button
  }()
  let trashImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "trash.fill")
    return imageView
  }()
  lazy var trashAddressLabel:UILabel = {
    let label = UILabel()
    label.text = "대한민국 대전광역시 동구 효동 148-9"
    label.textColor = .black
    return label
  }()
  lazy var trashDistanceLabel: UILabel = {
    let label = UILabel()
    label.text = "\(trashDistance)m"
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .black
    return label
  }()
  
  // pinRankingView
  let pinRankingView: UIView = {
    let view = UIView()
    return view
  }()
  let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "최고 이용 유저"
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .black
    return label
  }()
  lazy var firstUserImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = self.userProfileModel.Image
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 20
    return imageView
  }()
  let firstUserNameLabel: UILabel = {
    let label = UILabel()
    label.text = "iOS개발자 이치훈"
    label.font = .boldSystemFont(ofSize: 15)
    label.textColor = .black
    return label
  }()
  let firstUserHasPointLabel: UILabel = {
    let label = UILabel()
    label.text = "2500P"
    label.textColor = .black
    return label
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
        $0.top.equalToSuperview().offset(15)
        $0.trailing.equalToSuperview().inset(20)
        $0.leading.equalTo(trashAddressLabel.snp.trailing).offset(5)
        $0.height.equalTo(50)
        $0.width.equalTo(90)
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
    self.bottomSheetView.addSubview(handlerView)
    self.bottomSheetView.addSubview(pinDetailContainView)
    
    self.proFileView.addSubview(proFileImageView)
    self.proFileView.addSubview(profileNameLabel)
    //self.proFileView.addSubview(todaysPointView)
    self.proFileView.addSubview(cancelPinButton)
    self.proFileView.addSubview(profilePointLabel)
    
    self.pinDetailContainView.addSubview(pinDetailView)
    self.pinDetailView.addSubview(trashImageView)
    self.pinDetailView.addSubview(trashAddressLabel)
    self.pinDetailView.addSubview(trashDistanceLabel)
    
    self.pinDetailContainView.addSubview(pinRankingView)
    self.pinRankingView.addSubview(titleLabel)
    self.pinRankingView.addSubview(firstUserImageView)
    self.pinRankingView.addSubview(firstUserNameLabel)
    self.pinRankingView.addSubview(firstUserHasPointLabel)
    
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
    
    // profile contraint
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
    
    self.profileNameLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(18)
      $0.leading.equalTo(proFileImageView.snp.trailing).offset(10)
    }
    
//    self.todaysPointView.snp.makeConstraints {
//      $0.top.equalTo(profileNameLabel.snp.bottom).offset(7)
//      $0.leading.equalTo(proFileImageView.snp.trailing).offset(10)
//      $0.height.equalTo(30)
//      $0.width.equalTo(200)
//    }
    
    self.profilePointLabel.snp.makeConstraints {
      $0.centerY.equalTo(profileNameLabel.snp.centerY).offset(3)
      $0.leading.equalTo(profileNameLabel.snp.trailing).offset(10)
    }
    
    self.pinDetailContainView.snp.makeConstraints {
      $0.top.equalTo(proFileView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
    }
    
    self.pinDetailView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(70)
    }
    
    self.trashImageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(15)
      $0.leading.equalToSuperview().offset(35)
      $0.height.width.equalTo(50)
    }
    
    self.trashAddressLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(20)
      $0.leading.equalTo(trashImageView.snp.trailing).offset(10)
    }
    
    self.trashDistanceLabel.snp.makeConstraints {
      $0.leading.equalTo(trashImageView.snp.trailing).offset(10)
      $0.top.equalTo(trashAddressLabel.snp.bottom).offset(1)
    }
    
    self.pinRankingView.snp.makeConstraints {
      $0.top.equalTo(pinDetailView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    self.titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.leading.equalToSuperview().offset(35)
    }
    
    self.firstUserImageView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(5)
      $0.leading.equalToSuperview().offset(35)
      $0.height.width.equalTo(40)
    }
    
    self.firstUserNameLabel.snp.makeConstraints {
      $0.leading.equalTo(firstUserImageView.snp.trailing).offset(10)
      $0.centerY.equalTo(firstUserImageView.snp.centerY)
    }
    
    self.firstUserHasPointLabel.snp.makeConstraints {
      $0.centerY.equalTo(firstUserNameLabel).offset(3)
      $0.trailing.equalToSuperview().inset(25)
    }
  }

}
