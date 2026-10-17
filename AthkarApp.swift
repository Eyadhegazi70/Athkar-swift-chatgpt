import SwiftUI

@main
struct AthkarApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var locationManager = LocationManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var appIconManager = AppIconManager()
    @StateObject private var progressStore = DhikrProgressStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(notificationManager)
                .environmentObject(appIconManager)
                .environmentObject(progressStore)
                .environment(\.layoutDirection, .rightToLeft)
                .tint(.athkarGreen)
                .task {
                    locationManager.startUpdatesIfAuthorized()
                    await notificationManager.refreshAuthorizationStatus()
                    await notificationManager.scheduleEnabledRemindersIfAuthorized()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        locationManager.startUpdatesIfAuthorized()
                        Task {
                            await notificationManager.refreshAuthorizationStatus()
                            await notificationManager.scheduleEnabledRemindersIfAuthorized()
                        }
                        progressStore.refreshForNewDayIfNeeded()
                    } else {
                        locationManager.stopUpdates()
                    }
                }
        }
    }
}
