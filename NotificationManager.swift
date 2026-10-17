import Combine
import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var morningEnabled: Bool
    @Published var eveningEnabled: Bool
    @Published var middayEnabled: Bool
    @Published var morningTime: Date
    @Published var eveningTime: Date
    @Published var middayTime: Date
    @Published private(set) var message: String? = nil

    private let center = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard

    private enum Key {
        static let morningEnabled = "athkar.notifications.morningEnabled"
        static let eveningEnabled = "athkar.notifications.eveningEnabled"
        static let middayEnabled = "athkar.notifications.middayEnabled"
        static let morningTime = "athkar.notifications.morningTime"
        static let eveningTime = "athkar.notifications.eveningTime"
        static let middayTime = "athkar.notifications.middayTime"
    }

    private static let morningID = "athkar.daily.morning"
    private static let eveningID = "athkar.daily.evening"
    private static let middayID = "athkar.daily.midday"
    private static let managedIDs = [morningID, eveningID, middayID]

    override init() {
        let storedDefaults = UserDefaults.standard
        morningEnabled = storedDefaults.object(forKey: Key.morningEnabled) as? Bool ?? true
        eveningEnabled = storedDefaults.object(forKey: Key.eveningEnabled) as? Bool ?? true
        middayEnabled = storedDefaults.object(forKey: Key.middayEnabled) as? Bool ?? false
        morningTime = storedDefaults.object(forKey: Key.morningTime) as? Date ?? Self.time(hour: 6, minute: 0)
        eveningTime = storedDefaults.object(forKey: Key.eveningTime) as? Date ?? Self.time(hour: 17, minute: 30)
        middayTime = storedDefaults.object(forKey: Key.middayTime) as? Date ?? Self.time(hour: 12, minute: 0)
        super.init()
        center.delegate = self
    }

    var permissionDescription: String {
        switch authorizationStatus {
        case .authorized: return "الإشعارات مفعّلة"
        case .provisional: return "الإشعارات مفعّلة بهدوء"
        case .ephemeral: return "الإشعارات مفعّلة مؤقتًا"
        case .denied: return "الإشعارات مرفوضة من النظام"
        case .notDetermined: return "لم يتم طلب الإذن بعد"
        @unknown default: return "حالة الإشعارات غير معروفة"
        }
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorized || authorizationStatus == .provisional || authorizationStatus == .ephemeral
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestPermissionAndSchedule() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshAuthorizationStatus()
            guard granted || isAuthorized else {
                message = "لم يتم السماح بالإشعارات. يمكنك تفعيلها من إعدادات iPhone."
                return
            }
            await persistAndSchedule()
            message = "تم تفعيل تذكيرات الأذكار حسب الأوقات المختارة."
        } catch {
            message = "تعذّر طلب إذن الإشعارات: \(error.localizedDescription)"
        }
    }

    /// Persist current choices and update the operating system's repeating local notifications.
    func persistAndSchedule() async {
        defaults.set(morningEnabled, forKey: Key.morningEnabled)
        defaults.set(eveningEnabled, forKey: Key.eveningEnabled)
        defaults.set(middayEnabled, forKey: Key.middayEnabled)
        defaults.set(morningTime, forKey: Key.morningTime)
        defaults.set(eveningTime, forKey: Key.eveningTime)
        defaults.set(middayTime, forKey: Key.middayTime)
        await scheduleEnabledRemindersIfAuthorized()
    }

    func scheduleEnabledRemindersIfAuthorized() async {
        await refreshAuthorizationStatus()
        guard isAuthorized else { return }

        center.removePendingNotificationRequests(withIdentifiers: Self.managedIDs)
        var scheduledCount = 0
        if morningEnabled {
            await schedule(id: Self.morningID,
                           title: "أذكار الصباح ☀️",
                           body: "ابدأ يومك بذكر الله — حان وقت أذكار الصباح.",
                           at: morningTime)
            scheduledCount += 1
        }
        if eveningEnabled {
            await schedule(id: Self.eveningID,
                           title: "أذكار المساء 🌙",
                           body: "اختم يومك بذكر الله — حان وقت أذكار المساء.",
                           at: eveningTime)
            scheduledCount += 1
        }
        if middayEnabled {
            await schedule(id: Self.middayID,
                           title: "ذكر الله",
                           body: "خذ دقيقة للذكر والاستغفار والصلاة على النبي ﷺ.",
                           at: middayTime)
            scheduledCount += 1
        }
        message = scheduledCount == 0 ? "لا توجد تذكيرات مفعّلة." : "تمت جدولة \(scheduledCount) تذكيرات يومية."
    }

    func sendTestNotification() async {
        await refreshAuthorizationStatus()
        guard isAuthorized else {
            await requestPermissionAndSchedule()
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "تجربة إشعارات Athkar ✅"
        content.body = "تعمل الإشعارات المحلية من خلال نظام iOS."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "athkar.test.\(UUID().uuidString)", content: content, trigger: trigger)
        do {
            try await center.add(request)
            message = "سيصلك إشعار تجريبي بعد خمس ثوانٍ."
        } catch {
            message = "تعذّر جدولة الإشعار التجريبي: \(error.localizedDescription)"
        }
    }

    private func schedule(id: String, title: String, body: String, at time: Date) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.threadIdentifier = "athkar.daily"

        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.calendar = Calendar.current
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        do {
            try await center.add(request)
        } catch {
            message = "تعذّرت جدولة أحد التذكيرات: \(error.localizedDescription)"
        }
    }

    private static func time(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2001, month: 1, day: 1, hour: hour, minute: minute)) ?? .now
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification,
                                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
