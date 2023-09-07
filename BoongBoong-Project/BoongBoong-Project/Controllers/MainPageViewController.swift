import UIKit
import MapKit
import CoreLocation
import FloatingPanel

// MainPageViewController 클래스는 메인 화면에 대한 ViewController입니다.
class MainPageViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    
    // MARK: - Properties
    
    // 현재 사용 중인 사용자 정보를 저장하기 위한 변수입니다.
    var currentUsing: User?
    let locationManager = CLLocationManager()
    var fpc: FloatingPanelController!
    
    // Interface Builder에 있는 UI 요소에 대한 참조입니다.
    @IBOutlet weak var homeMap: MKMapView!
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var addKickboardButton: UIButton!
    @IBOutlet weak var returnKickboardButton: UIButton!
    
    var timer: Timer?
    var remainingTimeInSeconds = 0
    
    // MARK: - View Life Cycle
    
    // 뷰 컨트롤러가 메모리에 로드된 후 호출됩니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // 검색 바와 지도의 델리게이트 설정입니다.
        mapSearchBar.delegate = self
        mapSearchBar.placeholder = "위치 검색"
        homeMap.delegate = self
        
        // 지도를 탭했을 때의 제스처 인식기를 설정합니다.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        homeMap.addGestureRecognizer(tapGesture)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        homeMap.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillLayoutSubviews() {
        let user = UserDefaultsManager.shared.getUser()
        
        if (user?.registeredKickboard) != nil {
            addKickboardButton.isHidden = true
            
            if user?.isUsingKickboard == true {
                if timer == nil {
                    startTimer()
                    returnKickboardButton.isHidden = false
                }
            } else {
                timer?.invalidate()
                timer = nil
                returnKickboardButton.isHidden = true
            }
            
        } else {
            addKickboardButton.isHidden = false
            returnKickboardButton.isHidden = true
        }
        addKickboardMarkersToMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // 뷰가 화면에서 사라지기 직전에 호출됩니다.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Timer
        
    func startTimer() {
        if let history = UserDefaultsManager.shared.getUser()?.rideHistory.last {
            self.remainingTimeInSeconds = Int(history.endTime.timeIntervalSince(history.startTime))
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                return
            }
            
            if self.remainingTimeInSeconds > 0 {
                self.remainingTimeInSeconds -= 1

                DispatchQueue.main.async {
                    let minutes = self.remainingTimeInSeconds / 60
                    let seconds = self.remainingTimeInSeconds % 60
                    self.returnKickboardButton.setTitle(String(format: "%02d : %02d", minutes, seconds), for: .normal)
                }
            } else {
                timer.invalidate()
                self.timer = nil
                
                DispatchQueue.main.async {
                    self.returnKickboardButton.setTitle("반납하기", for: .normal)
                }
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            RunLoop.current.add(self.timer!, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    // MARK: - Bottom Sheet
    // 지도의 마커를 탭했을 때 호출됩니다.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? KickboardAnnotation {
            if let kickboard = getKickboardInfo(for: annotation) {
                configureFloatingPanel(for: kickboard)
            }
        }
        
        if let selectedAnnotation = view.annotation {
            mapView.removeAnnotation(selectedAnnotation)
        }
    }
    
    func addKickboardMarkersToMap() {
        if let kickboards = UserDefaultsManager.shared.getRegisteredKickboards()?.filter({$0.isBeingUsed == false}) {
            print(kickboards.count)
            for kickboard in kickboards {
                let annotation = KickboardAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: kickboard.latitude, longitude: kickboard.longitude)
                annotation.kickboard = kickboard
                homeMap.addAnnotation(annotation)
            }
        }
    }
    
    func configureFloatingPanel(for kickboard: Kickboard) {
        fpc = FloatingPanelController()
        //fpc.delegate = self
        
        let contentVC = UIStoryboard(name: "RentKickboardPage", bundle: nil).instantiateViewController(withIdentifier: "RentKickboard") as? RentKickboardViewController
        contentVC?.selectedKickboard = kickboard
        
        fpc.set(contentViewController: contentVC)
        fpc.changePanelStyle()
        fpc.layout = MyFloatingPanelLayout()
        fpc.contentMode = .static
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.isRemovalInteractionEnabled = true
        
        fpc.addPanel(toParent: self)
        
        homeMap.setCenter(CLLocationCoordinate2D(latitude: kickboard.latitude, longitude: kickboard.longitude), animated: true)
    }
    
    func getKickboardInfo(for annotation: KickboardAnnotation) -> Kickboard? {
        return annotation.kickboard
    }
    
    // MARK: - Actions
    
    // 지도 현위치 버른을 탭했을 때 호출될 액션입니다.
    @IBAction func mainPageregionButtonTapped(_ sender: UIButton) {
        if let userLocation = homeMap.userLocation.location {
          let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
            homeMap.setRegion(region, animated: true)
        }
    }
    
    // 킥보드 추가 버튼이 탭됐을 때 호출될 액션입니다.
    @IBAction func addKickboardButtonTapped(_ sender: UIButton) {
    }
    
    // 킥보드 반환 버튼이 탭됐을 때 호출될 액션입니다.
    @IBAction func returnKickboardButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "반납 확인", message: "현재 위치에 킥보드를 반납하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.performReturnKickboardAction()
        })
        present(alert, animated: true, completion: nil)
    }
    
    // FIXME: 작동 안함,.....위치,,,안불러옴.....
    func performReturnKickboardAction() {
        let userDefaultsManager = UserDefaultsManager.shared
        
        var (latitude, longitude) = (0.0, 0.0)
        if let userLocation = homeMap.userLocation.location {
            latitude = userLocation.coordinate.latitude
            longitude = userLocation.coordinate.longitude
        }

        DispatchQueue.main.async {
            print(latitude, longitude, 1)
        }
        
        // 1. 현재 사용자의 isUsingKickboard를 false로 변경, rideHistory에 endPosition 변경
        if var user = userDefaultsManager.getUser() {
            user.isUsingKickboard = false
            user.rideHistory[user.rideHistory.count-1].endPosition = Position(latitude: latitude, longitude: longitude)
            userDefaultsManager.saveUser(user)
        }
        
        // 2. 해당 킥보드의 isBeingUsed를 false로 변경
        if let user = userDefaultsManager.getUser(),
           var kickboards = userDefaultsManager.getRegisteredKickboards() {
            if let index = kickboards.firstIndex(where: { $0.id == user.rideHistory.last?.kickboardID }) {
                kickboards[index].isBeingUsed = false
                userDefaultsManager.saveRegisteredKickboards(kickboards)
            }
        }
        returnKickboardButton.isHidden = true
 
        // FIXME: 작동 왜 안함..?
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "알림"
        notificationContent.body = "킥보드 반납이 완료되었습니다"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)

        let request = UNNotificationRequest(identifier: "returnKickboardNotification", content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 추가 중 오류 발생: \(error.localizedDescription)")
            } else {
                print("알림이 성공적으로 추가되었습니다.")
            }
        }
    }
    
    // MARK: - Functions
    
    // 사용자가 검색 바에 텍스트를 입력할 때마다 호출
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        // 검색 범위를 서울특별시로 제한
        searchRequest.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), latitudinalMeters: 20000, longitudinalMeters: 20000)
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            if response == nil {
                print("Error")
            } else {
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                let annotations = self.homeMap.annotations
                self.homeMap.removeAnnotations(annotations)
                
                let annotation = MKPointAnnotation()
                annotation.title = searchText
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.homeMap.addAnnotation(annotation)
                
                let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
                self.homeMap.setRegion(coordinateRegion, animated: true)
            }
        }
    }

    // 지도의 영역이 변경되면 호출됩니다.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let southKoreaMaxLat: CLLocationDegrees = 38.634000
        let southKoreaMinLat: CLLocationDegrees = 33.004115
        let southKoreaMaxLon: CLLocationDegrees = 131.872699
        let southKoreaMinLon: CLLocationDegrees = 124.586300
            
        // 지도가 한국의 영역을 벗어나면 중심 좌표를 서울로 되돌립니다.
        if center.latitude > southKoreaMaxLat || center.latitude < southKoreaMinLat || center.longitude > southKoreaMaxLon || center.longitude < southKoreaMinLon {
            mapView.setCenter(CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), animated: true)
        }
    }


    // 지도를 탭했을 때의 액션입니다.
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: homeMap)
        let tappedCoordinate = homeMap.convert(locationInView, toCoordinateFrom: homeMap)
        
        // 기본 주석만 제거합니다.
        for annotation in homeMap.annotations {
            if annotation is CustomPointAnnotation {
                homeMap.removeAnnotation(annotation)
            }
        }
        
        // 새로운 주석을 추가합니다.
        let annotation = CustomPointAnnotation()
        annotation.isDefaultMarker = true  // 이 주석은 기본 마커를 사용합니다.
        annotation.coordinate = tappedCoordinate
        homeMap.addAnnotation(annotation)
        
        // 지도의 중심을 새로운 주석의 위치로 이동시킵니다.
        homeMap.setCenter(tappedCoordinate, animated: true)
    }

    func circularImageWithBorder(image: UIImage, targetSize: CGSize, borderWidth: CGFloat = 4.0, borderColor: UIColor = UIColor.purple) -> UIImage? {
        let diameter = min(targetSize.width, targetSize.height)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        
        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter)))
        path.addClip()
        image.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resultImage
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 사용자의 현재 위치에 대한 주석은 기본 뷰를 반환합니다.
        if annotation is MKUserLocation {
            return nil
        }
        
        // 사용자가 탭하여 추가한 주석을 처리
        if annotation is CustomPointAnnotation {
            let identifier = "pinAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.pinTintColor = .red
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        // 기본 마커 외의 마커들을 처리
        let identifier = "customAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        if let makerImage = UIImage(named: "Maker") {
            if let circularMakerImage = circularImageWithBorder(image: makerImage, targetSize: CGSize(width: 450, height: 300)) {
                annotationView?.image = circularMakerImage
            }
        }

        return annotationView
    }

    // 현재 사용자의 킥보드 사용 상태에 따라 버튼의 타이틀을 업데이트합니다.
    func updateKickboardButtonTitle() {
        if let user = currentUsing, user.isUsingKickboard {
            addKickboardButton.setTitle("탑승 중", for: .normal)
        }
    }
}

extension MainPageViewController: CLLocationManagerDelegate {
    
    // 위치 업데이트 시 호출되는 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let regionRadius: CLLocationDistance = 10000 // 10000m
            
            let region = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            homeMap.setRegion(region, animated: true)  // 수정된 부분
            manager.stopUpdatingLocation()
        }
    }
}

// 킥보드 마커를 위한 커스텀 어노테이션
class KickboardAnnotation: MKPointAnnotation {
    var kickboard: Kickboard?
}

class CustomPointAnnotation: MKPointAnnotation {
    var isDefaultMarker: Bool = false
}

