//
//  RentKickboardViewController.swift
//  BoongBoong-Project
//
//  Created by 이재희 on 2023/09/06.
//

import UIKit
import FloatingPanel
import CoreLocation
import MapKit

final class RentKickboardViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var kickboardImage: UIImageView!
    @IBOutlet weak var kickboardName: UILabel!
    @IBOutlet weak var kickboardDistance: UILabel!
    @IBOutlet weak var kickboardRegion: UILabel!
    @IBOutlet weak var rentButton: UIButton!
    
    var selectedKickboard: Kickboard?
    var userLocation: Position?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kickboardImage.layer.cornerRadius = 20
        if let kickboard = selectedKickboard {
            kickboardImage.image = UIImage(data: kickboard.boongboongImage)
            kickboardName.text = kickboard.boongboongName
            
            // TODO: 내 위치 가져오기
            let userLatitude = userLocation?.latitude
            let userLongitude = userLocation?.longitude
            let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
            
            let kickboardLocation = CLLocation(latitude: kickboard.latitude, longitude: kickboard.longitude)
            let distanceInMeters = userLocation.distance(from: kickboardLocation)
            let distanceInKilometers = distanceInMeters / 1000.0
            kickboardDistance.text = String(format: "%.1f km", distanceInKilometers)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(kickboardLocation) { (placemarks, error) in
                if let error = error {
                    print("Reverse Geocoding Error: \(error.localizedDescription)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    if let address = placemark.name {
                        self.kickboardRegion.text = address
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func rentButtonTapped(_ sender: UIButton) {
        
        let userDefaultsManager = UserDefaultsManager.shared
        
        let alert = UIAlertController(title: "대여 시간 선택", message: "대여하실 시간을 선택해주세요", preferredStyle: .alert)
                        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .countDownTimer
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.minuteInterval = 10
                
        let vc = UIViewController()
        vc.view = datePicker
                
        alert.setValue(vc, forKey: "contentViewController")
        
        var selectedHours = 0
        var selectedMinutes = 0
        
        let confirmAction = UIAlertAction(title: "선택 완료", style: .default) { (_) in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: datePicker.date)
            selectedHours = components.hour ?? 0
            selectedMinutes = components.minute ?? 0
            
            print("선택된 대여 시간: \(selectedHours)시간 \(selectedMinutes)분")
            
            let anotherAlert = UIAlertController(title: "대여 확인", message: "\(selectedHours)시간 \(selectedMinutes)분 대여하시겠습니까?", preferredStyle: .alert)
            
            let anotherConfirmAction = UIAlertAction(title: "확인", style: .default) { (_) in
                // 1. 현재 사용자의 isUsingKickboard를 true로 변경
                if var user = userDefaultsManager.getUser() {
                    user.isUsingKickboard = true
                    userDefaultsManager.saveUser(user)
                }

                // 2. 현재 사용자의 rideHistory에 추가 (예: 현재 시간을 추가)
                // FIXME: 위치 받아와서 내용 수정하기
                let boongboongName = self.selectedKickboard?.boongboongName
                let startTime = Date()
                let endTime = Calendar.current.date(byAdding: .minute, value: selectedHours * 60 + selectedMinutes, to: startTime)!
                let startPosition = Position(latitude: 37.1234, longitude: 126.5678)
                let endPosition = Position(latitude: 37.5678, longitude: 127.1234)

                // 대여 기록 추가
                userDefaultsManager.updateRideHistory(with: RideHistory(boongboongName: boongboongName!, startTime: startTime, endTime: endTime, startPosition: startPosition, endPosition: endPosition))

                // 3. 해당 킥보드의 isBeingUsed를 true로 변경
                if let selectedKickboard = self.selectedKickboard, var kickboards = userDefaultsManager.getRegisteredKickboards() {
                    if let index = kickboards.firstIndex(where: { $0.id == selectedKickboard.id }) {
                        kickboards[index].isBeingUsed = true
                        userDefaultsManager.saveRegisteredKickboards(kickboards)
                    }
                }
                
                let main = MainPageViewController.sharedInstance?.homeMap
                if let selectedKickboard = self.selectedKickboard {
                    let kickboardLocation = CLLocationCoordinate2D(latitude: selectedKickboard.latitude, longitude: selectedKickboard.longitude)

                    let regionRadius: CLLocationDistance = 1500
                    let coordinateRegion = MKCoordinateRegion(
                        center: kickboardLocation,
                        latitudinalMeters: regionRadius,
                        longitudinalMeters: regionRadius
                    )
                    main?.setRegion(coordinateRegion, animated: true)
                }

                MainPageViewController.sharedInstance?.addKickboardMarkersToMap()
                let existingAnnotations = main!.annotations.filter { $0 is KickboardAnnotation }
                main!.removeAnnotations(existingAnnotations)
                self.dismiss(animated: true)
            }
            anotherAlert.addAction(anotherConfirmAction)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            anotherAlert.addAction(cancelAction)

            self.present(anotherAlert, animated: true, completion: nil)
        }
        alert.addAction(confirmAction)
                
        present(alert, animated: true)
        
    }
    
    @objc func handleTitleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            dismiss(animated: true, completion: nil)
        }
    }
    
}


// MARK: - FloatingPanelController

extension FloatingPanelController {
    func changePanelStyle() {
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: -4.0)
        shadow.opacity = 0.15
        shadow.radius = 2
        appearance.shadows = [shadow]
        appearance.cornerRadius = 15.0
        appearance.backgroundColor = .clear
        appearance.borderColor = .clear
        appearance.borderWidth = 0

        surfaceView.grabberHandle.isHidden = true
        surfaceView.appearance = appearance
    }
}

class MyFloatingPanelLayout: FloatingPanelLayout {

    var position: FloatingPanelPosition {
        return .bottom
    }

    var initialState: FloatingPanelState {
        return .half
    }

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.35, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.2
    }
}
