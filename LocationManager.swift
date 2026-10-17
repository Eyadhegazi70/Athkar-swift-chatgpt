import CoreLocation
import Combine
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var coordinate: CLLocationCoordinate2D?
    @Published private(set) var trueHeading: CLLocationDirection?
    @Published private(set) var headingAccuracy: CLLocationDirection = -1
    @Published private(set) var horizontalAccuracy: CLLocationAccuracy?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var errorMessage: String?
    @Published private(set) var isUpdating = false
    @Published private(set) var headingUsesTrueNorth = false

    private let manager = CLLocationManager()
    private var lastHeadingPublish = Date.distantPast

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
        manager.headingFilter = 1
        manager.pausesLocationUpdatesAutomatically = true
        authorizationStatus = manager.authorizationStatus
    }

    /// Starts high-accuracy foreground location and compass updates after permission is granted.
    func startUpdatesIfAuthorized() {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            errorMessage = nil
            manager.startUpdatingLocation()
            if CLLocationManager.headingAvailable() {
                manager.startUpdatingHeading()
            }
            isUpdating = true
            // Ask for a fresh one-shot fix as well, especially after a long pause or travel.
            manager.requestLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            errorMessage = "إذن الموقع غير متاح. فعّله من إعدادات iPhone لحساب اتجاه القبلة تلقائيًا."
            isUpdating = false
        @unknown default:
            errorMessage = "تعذّر التحقق من إذن الموقع."
            isUpdating = false
        }
    }

    func requestPermission() {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            startUpdatesIfAuthorized()
        }
    }

    func stopUpdates() {
        guard isUpdating else { return }
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        isUpdating = false
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            errorMessage = nil
            startUpdatesIfAuthorized()
        case .denied, .restricted:
            errorMessage = "إذن الموقع مرفوض. يمكنك تغييره من الإعدادات."
        case .notDetermined:
            break
        @unknown default:
            errorMessage = "حالة إذن الموقع غير معروفة."
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              location.horizontalAccuracy >= 0,
              abs(location.timestamp.timeIntervalSinceNow) < 120 else { return }

        coordinate = location.coordinate
        horizontalAccuracy = location.horizontalAccuracy
        errorMessage = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else {
            headingAccuracy = newHeading.headingAccuracy
            return
        }

        // Core Location's true heading is relative to geographic north when available.
        let hasTrueHeading = newHeading.trueHeading >= 0
        let candidate = hasTrueHeading ? newHeading.trueHeading : newHeading.magneticHeading
        guard candidate.isFinite else { return }

        // Avoid publishing excessively frequent sensor samples; the compass remains responsive.
        let now = Date()
        if now.timeIntervalSince(lastHeadingPublish) < 0.04,
           let current = trueHeading,
           abs(Self.angularDifference(candidate, current)) < 0.5 {
            return
        }
        lastHeadingPublish = now
        trueHeading = Self.normalized(candidate)
        headingAccuracy = newHeading.headingAccuracy
        headingUsesTrueNorth = hasTrueHeading
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let clError = error as? CLError
        if clError?.code == .locationUnknown {
            // Temporary loss of GPS signal: keep the last valid coordinate.
            return
        }
        if clError?.code == .denied {
            authorizationStatus = .denied
            errorMessage = "تعذّر الوصول إلى الموقع. راجع أذونات الخصوصية في إعدادات الجهاز."
            return
        }
        errorMessage = "تعذّر تحديد موقعك حاليًا. حاول مرة أخرى في مكان مفتوح."
    }

    private static func normalized(_ degrees: Double) -> Double {
        let result = degrees.truncatingRemainder(dividingBy: 360)
        return result >= 0 ? result : result + 360
    }

    private static func angularDifference(_ lhs: Double, _ rhs: Double) -> Double {
        let difference = abs(lhs - rhs).truncatingRemainder(dividingBy: 360)
        return min(difference, 360 - difference)
    }
}
