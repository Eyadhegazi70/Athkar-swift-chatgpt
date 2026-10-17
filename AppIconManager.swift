import Combine
import SwiftUI
import UIKit

@MainActor
final class AppIconManager: ObservableObject {
    @Published private(set) var activeIconName: String?
    @Published private(set) var message: String?
    @Published private(set) var isChanging = false

    init() {
        activeIconName = UIApplication.shared.alternateIconName
    }

    var supportsAlternateIcons: Bool {
        UIApplication.shared.supportsAlternateIcons
    }

    func isSelected(_ icon: AthkarAppIcon) -> Bool {
        activeIconName == icon.assetName
    }

    func setIcon(_ icon: AthkarAppIcon) async {
        guard supportsAlternateIcons else {
            message = "تغيير الأيقونة غير مدعوم في هذه النسخة من التطبيق."
            return
        }
        guard !isChanging else { return }
        isChanging = true
        defer { isChanging = false }
        do {
            try await UIApplication.shared.setAlternateIconName(icon.assetName)
            activeIconName = icon.assetName
            message = "تم تحديث أيقونة التطبيق."
        } catch {
            message = "لم يتسن تغيير الأيقونة: \(error.localizedDescription)"
        }
    }
}

enum AthkarAppIcon: String, CaseIterable, Identifiable {
    case moon
    case beads
    case dome

    var id: String { rawValue }

    /// This must match the alternate icon asset name configured in the Xcode target.
    var assetName: String? {
        switch self {
        case .moon: return nil // nil restores the primary AppIcon
        case .beads: return "AppIcon-Beads"
        case .dome: return "AppIcon-Dome"
        }
    }

    var title: String {
        switch self {
        case .moon: return "الهلال"
        case .beads: return "المسبحة"
        case .dome: return "القبة"
        }
    }

    var symbol: String {
        switch self {
        case .moon: return "moon.stars.fill"
        case .beads: return "circle.hexagongrid.fill"
        case .dome: return "building.columns.fill"
        }
    }

    var color: Color {
        switch self {
        case .moon: return Color(red: 0.10, green: 0.28, blue: 0.25)
        case .beads: return Color(red: 0.22, green: 0.40, blue: 0.32)
        case .dome: return Color(red: 0.16, green: 0.31, blue: 0.44)
        }
    }
}
