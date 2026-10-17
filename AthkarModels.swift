import Combine
import Foundation

struct Dhikr: Identifiable, Hashable {
    let id: String
    let text: String
    let repetitions: Int
    let source: String?
}

enum DhikrCategory: String, CaseIterable, Identifiable, Hashable {
    case morning
    case evening
    case sleep

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: return "أذكار الصباح"
        case .evening: return "أذكار المساء"
        case .sleep: return "أذكار النوم"
        }
    }

    var subtitle: String {
        switch self {
        case .morning: return "ابدأ يومك بذكر الله"
        case .evening: return "اختم يومك بالطمأنينة"
        case .sleep: return "أذكار قبل النوم"
        }
    }

    var symbol: String {
        switch self {
        case .morning: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        case .sleep: return "bed.double.fill"
        }
    }

    var tint: String {
        switch self {
        case .morning: return "morning"
        case .evening: return "evening"
        case .sleep: return "sleep"
        }
    }

    var items: [Dhikr] {
        switch self {
        case .morning: return AdhkarData.morning
        case .evening: return AdhkarData.evening
        case .sleep: return AdhkarData.sleep
        }
    }
}

@MainActor
final class DhikrProgressStore: ObservableObject {
    @Published private(set) var counts: [String: Int] = [:]
    private var loadedDayKey = ""

    init() {
        loadForToday()
    }

    func count(for item: Dhikr) -> Int {
        min(counts[item.id, default: 0], item.repetitions)
    }

    func isComplete(_ item: Dhikr) -> Bool {
        count(for: item) >= item.repetitions
    }

    /// Counts persist for the current local day and start fresh on the next day.
    func advance(_ item: Dhikr) {
        refreshForNewDayIfNeeded()
        let current = count(for: item)
        counts[item.id] = current >= item.repetitions ? 0 : current + 1
        UserDefaults.standard.set(counts, forKey: loadedDayKey)
    }

    func reset(_ item: Dhikr) {
        counts[item.id] = 0
        UserDefaults.standard.set(counts, forKey: loadedDayKey)
    }

    func refreshForNewDayIfNeeded() {
        let today = Self.key(for: Date())
        guard today != loadedDayKey else { return }
        loadForToday()
    }

    private func loadForToday() {
        loadedDayKey = Self.key(for: Date())
        counts = UserDefaults.standard.dictionary(forKey: loadedDayKey) as? [String: Int] ?? [:]
    }

    private static func key(for date: Date) -> String {
        let start = Calendar.current.startOfDay(for: date)
        return "athkar.progress.\(Int(start.timeIntervalSince1970))"
    }
}
