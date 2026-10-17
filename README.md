# Athkar — native SwiftUI iOS app

A native SwiftUI implementation of the requested Athkar core experience. It does not use HTML, JavaScript, or web views and has no third-party package dependencies.

## Included

- Arabic RTL interface with Home, Adhkar, Qibla, Tasbih, and Settings tabs.
- Core Location with automatic GPS updates when authorized, foreground compass updates, true-heading use where available, and a computed initial bearing and great-circle distance to the Kaaba (`21.4225, 39.8262`).
- Local daily reminders for morning, evening, and an optional midday dhikr using `UNUserNotificationCenter` and repeating `UNCalendarNotificationTrigger` requests.
- App icon selector calling `UIApplication.shared.setAlternateIconName`, with the primary moon icon plus bundled alternate icon sets named `AppIcon-Beads` and `AppIcon-Dome`.
- Locally persisted daily dhikr counters and tasbih totals.
- Location permission usage text and iOS asset catalog included.

## Open and run

1. Open `Athkar.xcodeproj` in Xcode 16 or newer.
2. Select the **Athkar** target, then choose your own unique **Bundle Identifier** instead of `com.example.Athkar`.
3. In **Signing & Capabilities**, select your Apple development team for running on a physical iPhone.
4. Select an iPhone simulator or your iPhone and press **Run**.
5. Allow Location when the app asks. For compass tests, use a physical iPhone where possible; a simulator cannot reproduce real compass sensor behavior.
6. In Settings, enable notifications and permit them when iOS prompts. The test action schedules a local notification about five seconds later.

## Alternate app icons

The target's build settings are configured with:

- Primary icon: `AppIcon`
- Alternate icons: `AppIcon-Beads AppIcon-Dome`

Keep these names in sync if renaming the icon sets. Xcode generates the `CFBundleAlternateIcons` entries from the asset catalog/build settings; don't manually edit the generated alternate-icon plist entries. `nil` in `setAlternateIconName` switches back to the primary icon.

## Privacy strings and background behavior

`Info.plist` declares `NSLocationWhenInUseUsageDescription`. Location and compass updates are foreground-only and are stopped when the app backgrounds to avoid unnecessary battery use. Local notification delivery is owned by iOS after each request is scheduled; it does not require the app to remain running. This app does not request Always location permission or background location mode.

## Scope notes

The supplied HTML/CSS/JavaScript has additional functionality beyond the requirements listed in the request. This SwiftUI project ports the main Arabic experience and the requested GPS/Qibla, local-notification, tasbih, adhkar-progress, and app-icon workflows; it does **not** claim to be a line-by-line port of the web source's full Quran reader, astronomical prayer-time calculation engine, or developer diagnostics. The bundled adhkar list is curated and should be reviewed against the publisher's preferred verified source before an App Store release.

No Xcode/iOS SDK is available in the build environment used to create these files, so an Apple-platform build and real-device sensor test have not been performed here. Run the project in Xcode and verify location permission, heading calibration, notification timing, and icon switching on supported iOS versions before shipping.
