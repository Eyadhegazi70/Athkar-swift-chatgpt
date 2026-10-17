import CoreLocation
import SwiftUI
import UIKit

// MARK: - App shell

enum AppTab: String, CaseIterable, Identifiable {
    case home, adhkar, qibla, tasbih, settings
    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "الرئيسية"
        case .adhkar: return "الأذكار"
        case .qibla: return "القبلة"
        case .tasbih: return "السبحة"
        case .settings: return "الإعدادات"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .adhkar: return "text.book.closed.fill"
        case .qibla: return "location.north.circle.fill"
        case .tasbih: return "circle.dotted.circle.fill"
        case .settings: return "slider.horizontal.3"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        VStack(spacing: 0) {
            header
            ZStack {
                switch selectedTab {
                case .home:
                    HomeView(onSelect: selectTab)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                case .adhkar:
                    AdhkarTabView()
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                case .qibla:
                    QiblaView()
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                case .tasbih:
                    TasbihView()
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                case .settings:
                    SettingsView()
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            bottomBar
        }
        .background {
            LinearGradient(colors: [Color.athkarBackground, Color(uiColor: .systemGroupedBackground)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.20), value: selectedTab)
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(LinearGradient(colors: [.athkarGreen, .athkarDeepGreen], startPoint: .topLeading, endPoint: .bottomTrailing))
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedTab == .home ? "Athkar" : selectedTab.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.athkarInk)
                Text(selectedTab == .home ? "رفيقك اليومي للذكر" : "طمأنينةٌ تبدأ بذكر الله")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            if selectedTab == .home {
                Button { selectTab(.settings) } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.athkarInk)
                        .frame(width: 42, height: 42)
                        .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("الإعدادات")
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var bottomBar: some View {
        HStack(spacing: 3) {
            ForEach(AppTab.allCases) { tab in
                Button { selectTab(tab) } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 19, weight: selectedTab == tab ? .semibold : .regular))
                            .symbolRenderingMode(.hierarchical)
                        Text(tab.title)
                            .font(.system(size: 10.5, weight: selectedTab == tab ? .bold : .medium))
                    }
                    .foregroundStyle(selectedTab == tab ? Color.athkarGreen : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .fill(Color.athkarGreen.opacity(0.10))
                                .padding(.horizontal, 2)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 23, style: .continuous).stroke(Color.black.opacity(0.045), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 5)
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private func selectTab(_ tab: AppTab) {
        withAnimation(.easeInOut(duration: 0.20)) { selectedTab = tab }
    }
}

// MARK: - Home

private struct HomeView: View {
    let onSelect: (AppTab) -> Void
    @EnvironmentObject private var locationManager: LocationManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(LinearGradient(colors: [Color.athkarGreen, Color.athkarDeepGreen], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Circle().fill(Color.white.opacity(0.07)).frame(width: 185, height: 185).offset(x: 180, y: -75)
                    Circle().stroke(Color.white.opacity(0.10), lineWidth: 1).frame(width: 210, height: 210).offset(x: 165, y: 35)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("وَاذْكُر رَّبَّكَ كَثِيرًا")
                                .font(.system(size: 13, weight: .semibold, design: .serif))
                                .foregroundStyle(.white.opacity(0.9))
                            Spacer()
                            Image(systemName: "sparkles")
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        Text("اجعل للذكر\nمكانًا في يومك")
                            .font(.system(size: 29, weight: .bold, design: .rounded))
                            .lineSpacing(4)
                            .foregroundStyle(.white)
                        Text("لحظات قليلة من التسبيح والدعاء تمنح يومك سكينة.")
                            .font(.system(size: 13.5, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(3)
                        Button { onSelect(.adhkar) } label: {
                            HStack(spacing: 8) {
                                Text("ابدأ الأذكار")
                                Image(systemName: "arrow.left")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.athkarDeepGreen)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .background(.white, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(22)
                }
                .frame(minHeight: 252)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                HStack(spacing: 11) {
                    InfoTile(symbol: "location.north.circle.fill", title: "اتجاه القبلة", detail: locationManager.coordinate == nil ? "حدّد موقعك" : "جاهز للحساب", tint: .athkarBlue) {
                        onSelect(.qibla)
                    }
                    InfoTile(symbol: "circle.dotted.circle.fill", title: "السبحة", detail: "تسبيحك اليومي", tint: .athkarGreen) {
                        onSelect(.tasbih)
                    }
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("وردك اليومي")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(Color.athkarInk)
                        Text("اختر الذكر المناسب للوقت")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("عرض الكل") { onSelect(.adhkar) }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.athkarGreen)
                }
                VStack(spacing: 10) {
                    ForEach([DhikrCategory.morning, .evening, .sleep]) { category in
                        Button { onSelect(.adhkar) } label: {
                            HStack(spacing: 13) {
                                Image(systemName: category.symbol)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.athkarGreen)
                                    .frame(width: 46, height: 46)
                                    .background(Color.athkarGreen.opacity(0.10), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.title).font(.system(size: 15, weight: .bold)).foregroundStyle(Color.athkarInk)
                                    Text(category.subtitle).font(.system(size: 12)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(13)
                            .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 19, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text("يعمل التطبيق بالموقع والبوصلة المدمجين في iPhone، وتتم جدولة التذكيرات محليًا على الجهاز.")
                    .font(.system(size: 11.5))
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .padding(.horizontal, 3)
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 20)
        }
    }
}

private struct InfoTile: View {
    let symbol: String
    let title: String
    let detail: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 11) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(size: 15, weight: .bold)).foregroundStyle(Color.athkarInk)
                    Text(detail).font(.system(size: 12)).foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 21, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Adhkar

private struct AdhkarTabView: View {
    @State private var selectedCategory: DhikrCategory?
    @EnvironmentObject private var progressStore: DhikrProgressStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 17) {
                if let category = selectedCategory {
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) { selectedCategory = nil }
                    } label: {
                        Label("جميع الأذكار", systemImage: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.athkarGreen)
                    }
                    .buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.title).font(.system(size: 24, weight: .bold)).foregroundStyle(Color.athkarInk)
                        Text("اضغط على بطاقة الذكر لتسجيل التكرار.")
                            .font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    ForEach(category.items) { item in
                        DhikrCard(item: item)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("حصنك اليومي")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.athkarInk)
                        Text("اختر مجموعة الأذكار، وتابع عدد مرات القراءة.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    ForEach(DhikrCategory.allCases) { category in
                        Button {
                            withAnimation(.easeInOut(duration: 0.18)) { selectedCategory = category }
                        } label: {
                            HStack(spacing: 13) {
                                Image(systemName: category.symbol)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(Color.athkarGreen)
                                    .frame(width: 52, height: 52)
                                    .background(Color.athkarGreen.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(category.title).font(.system(size: 16, weight: .bold)).foregroundStyle(Color.athkarInk)
                                    Text(category.subtitle).font(.system(size: 12)).foregroundStyle(.secondary)
                                    Text("\(category.items.count) أذكار")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Color.athkarGreen)
                                }
                                Spacer()
                                Image(systemName: "chevron.left").font(.system(size: 12, weight: .bold)).foregroundStyle(.tertiary)
                            }
                            .padding(15)
                            .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 21, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.athkarGreen)
                        Text("تُحفظ عدّادات الأذكار لهذا اليوم على الجهاز.")
                            .font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 7)
            .padding(.bottom, 20)
        }
    }
}

private struct DhikrCard: View {
    let item: Dhikr
    @EnvironmentObject private var progressStore: DhikrProgressStore

    private var count: Int { progressStore.count(for: item) }
    private var complete: Bool { progressStore.isComplete(item) }
    private var progress: Double { item.repetitions > 0 ? Double(count) / Double(item.repetitions) : 0 }

    var body: some View {
        Button { progressStore.advance(item) } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if let source = item.source {
                        Text(source)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.athkarGreen)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.athkarGreen.opacity(0.09), in: Capsule())
                    } else {
                        Text("ذِكر")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.black.opacity(0.04), in: Capsule())
                    }
                    Spacer()
                    Image(systemName: complete ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(complete ? Color.athkarGreen : Color.secondary.opacity(0.4))
                }
                Text(item.text)
                    .font(.system(size: 21, weight: .regular, design: .serif))
                    .lineSpacing(9)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.athkarInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 3)
                HStack(spacing: 10) {
                    Text(complete ? "اكتمل الذكر" : "اضغط للتكرار")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(complete ? Color.athkarGreen : Color.secondary)
                    Spacer()
                    Text("\(count) / \(item.repetitions)")
                        .font(.system(size: 13, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(Color.athkarGreen)
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.athkarGreen.opacity(0.12))
                        GeometryReader { proxy in
                            Capsule().fill(Color.athkarGreen)
                                .frame(width: proxy.size.width * progress)
                        }
                    }
                    .frame(width: 54, height: 6)
                }
            }
            .padding(16)
            .background(.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.black.opacity(0.045), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.text). العدد \(count) من \(item.repetitions)")
        .accessibilityHint(complete ? "اضغط لإعادة العدّاد إلى الصفر" : "اضغط لتسجيل قراءة الذكر مرة أخرى")
    }
}

// MARK: - Qibla

private struct QiblaView: View {
    @EnvironmentObject private var locationManager: LocationManager

    private var bearing: Double? {
        guard let coordinate = locationManager.coordinate else { return nil }
        return QiblaMath.initialBearing(from: coordinate)
    }

    private var heading: Double { locationManager.trueHeading ?? 0 }
    private var distance: Double? {
        guard let coordinate = locationManager.coordinate else { return nil }
        return QiblaMath.distanceKilometers(from: coordinate)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                VStack(spacing: 5) {
                    Text("اتجاه القبلة")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.athkarInk)
                    Text("يُحسب الاتجاه من موقعك الحالي إلى الكعبة المشرفة")
                        .font(.system(size: 12.5))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                if let bearing {
                    ZStack {
                        Circle().fill(.white.opacity(0.96))
                        Circle().stroke(Color.athkarGreen.opacity(0.12), lineWidth: 1)
                            .padding(6)
                        ForEach(0..<72, id: \.self) { tick in
                            Capsule()
                                .fill(tick.isMultiple(of: 6) ? Color.athkarInk.opacity(0.65) : Color.secondary.opacity(0.32))
                                .frame(width: tick.isMultiple(of: 6) ? 2.2 : 1.2,
                                       height: tick.isMultiple(of: 6) ? 13 : 6)
                                .offset(y: -127)
                                .rotationEffect(.degrees(Double(tick) * 5))
                        }
                        VStack {
                            Text("شمال")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.red.opacity(0.85))
                            Spacer()
                            Text("جنوب")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 21)
                        HStack {
                            Text("غرب").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                            Spacer()
                            Text("شرق").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 19)
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 78, weight: .medium))
                            .foregroundStyle(LinearGradient(colors: [Color.athkarGreen, Color.athkarDeepGreen], startPoint: .top, endPoint: .bottom))
                            .offset(y: -9)
                            .rotationEffect(.degrees(bearing))
                        Circle().fill(.white).frame(width: 13, height: 13)
                            .overlay(Circle().stroke(Color.athkarGreen, lineWidth: 2))
                    }
                    .frame(width: 290, height: 290)
                    .rotationEffect(.degrees(-heading))
                    .animation(.easeOut(duration: 0.16), value: heading)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("بوصلة القبلة")
                    .accessibilityValue("اتجاه القبلة \(Int(bearing.rounded())) درجة من الشمال الحقيقي")

                    VStack(spacing: 4) {
                        Text("\(Int(bearing.rounded()))°")
                            .font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(Color.athkarGreen)
                        Text("من الشمال الحقيقي")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 10) {
                        metricCard(title: "المسافة إلى مكة", value: distance.map { String(format: "%.0f كم", $0) } ?? "—", symbol: "point.topleft.down.to.point.bottomright.curvepath")
                        metricCard(title: "دقة البوصلة", value: locationManager.headingAccuracy >= 0 ? "±\(Int(locationManager.headingAccuracy.rounded()))°" : "—", symbol: "scope")
                    }
                    .padding(.top, 1)
                    if !locationManager.headingUsesTrueNorth {
                        Label("قد تستخدم البوصلة الشمال المغناطيسي مؤقتًا. حرّك الهاتف على شكل رقم ٨ للمعايرة.", systemImage: "info.circle")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                } else {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 58))
                        .foregroundStyle(Color.athkarGreen)
                        .padding(.top, 26)
                    Text("نحتاج إلى موقعك لحساب اتجاه القبلة")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.athkarInk)
                        .multilineTextAlignment(.center)
                    Text(locationManager.errorMessage ?? "اسمح للتطبيق باستخدام الموقع أثناء الاستعمال. لا تُستخدم أي مدينة ثابتة؛ يُحسب الاتجاه من إحداثيات GPS.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    Button { locationManager.requestPermission() } label: {
                        Label("تحديد موقعي الآن", systemImage: "location.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(15)
                            .background(Color.athkarGreen, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                if let coordinate = locationManager.coordinate {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("معلومات الموقع", systemImage: "location.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.athkarInk)
                        HStack {
                            Text("خط العرض").foregroundStyle(.secondary)
                            Spacer()
                            Text(String(format: "%.5f°", coordinate.latitude)).monospacedDigit()
                        }
                        HStack {
                            Text("خط الطول").foregroundStyle(.secondary)
                            Spacer()
                            Text(String(format: "%.5f°", coordinate.longitude)).monospacedDigit()
                        }
                        if let accuracy = locationManager.horizontalAccuracy {
                            HStack {
                                Text("دقة GPS التقريبية").foregroundStyle(.secondary)
                                Spacer()
                                Text("±\(Int(accuracy.rounded())) م").monospacedDigit()
                            }
                        }
                        Button { locationManager.startUpdatesIfAuthorized() } label: {
                            Label("تحديث الموقع", systemImage: "arrow.clockwise")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.athkarGreen)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 3)
                    }
                    .font(.system(size: 13))
                    .padding(15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 19, style: .continuous))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }

    private func metricCard(title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol).font(.system(size: 17, weight: .semibold)).foregroundStyle(Color.athkarGreen)
            Text(title).font(.system(size: 11)).foregroundStyle(.secondary)
            Text(value).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(Color.athkarInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private enum QiblaMath {
    static let kaaba = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)

    static func initialBearing(from coordinate: CLLocationCoordinate2D) -> Double {
        let latitude = coordinate.latitude * .pi / 180
        let kaabaLatitude = kaaba.latitude * .pi / 180
        let longitudeDelta = (kaaba.longitude - coordinate.longitude) * .pi / 180
        let y = sin(longitudeDelta) * cos(kaabaLatitude)
        let x = cos(latitude) * sin(kaabaLatitude) - sin(latitude) * cos(kaabaLatitude) * cos(longitudeDelta)
        let degrees = atan2(y, x) * 180 / .pi
        let normalized = degrees.truncatingRemainder(dividingBy: 360)
        return normalized >= 0 ? normalized : normalized + 360
    }

    static func distanceKilometers(from coordinate: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6_371.0088
        let lat1 = coordinate.latitude * .pi / 180
        let lat2 = kaaba.latitude * .pi / 180
        let deltaLat = (kaaba.latitude - coordinate.latitude) * .pi / 180
        let deltaLon = (kaaba.longitude - coordinate.longitude) * .pi / 180
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)
        let clamped = min(1, max(0, a))
        return earthRadius * 2 * atan2(sqrt(clamped), sqrt(1 - clamped))
    }
}

// MARK: - Tasbih

private struct TasbihView: View {
    @AppStorage("athkar.tasbih.count") private var count = 0
    @AppStorage("athkar.tasbih.total") private var total = 0
    @AppStorage("athkar.tasbih.rounds") private var rounds = 0
    @AppStorage("athkar.tasbih.target") private var target = 33
    @State private var showResetConfirmation = false

    private var progress: Double { target > 0 ? Double(count % target) / Double(target) : 0 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("سبّح واذكر الله")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.athkarInk)
                    Text("اضغط على الدائرة لتسجيل تسبيحة")
                        .font(.system(size: 13)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    Circle().stroke(Color.athkarGreen.opacity(0.12), lineWidth: 14)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AngularGradient(colors: [.athkarGreen, .athkarBlue, .athkarGreen], center: .center), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.14), value: progress)
                    Circle().fill(.white.opacity(0.95)).padding(17)
                    VStack(spacing: 7) {
                        Text("التسبيحات")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text("\(target == 0 ? count : count % target)")
                            .font(.system(size: 68, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(Color.athkarGreen)
                            .contentTransition(.numericText())
                        Text("من \(target)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 260, height: 260)
                .contentShape(Circle())
                .onTapGesture(perform: increment)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("عداد السبحة")
                .accessibilityValue("\(target == 0 ? count : count % target) من \(target)")
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { increment() }

                Button(action: increment) {
                    HStack(spacing: 9) {
                        Image(systemName: "plus.circle.fill")
                        Text("تسبيحة واحدة")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(LinearGradient(colors: [.athkarGreen, .athkarDeepGreen], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)

                HStack(spacing: 10) {
                    stat(title: "الإجمالي", value: total)
                    stat(title: "الجولات المكتملة", value: rounds)
                }
                VStack(alignment: .leading, spacing: 11) {
                    Text("هدف الجولة").font(.system(size: 14, weight: .bold)).foregroundStyle(Color.athkarInk)
                    Picker("هدف الجولة", selection: $target) {
                        Text("33").tag(33)
                        Text("99").tag(99)
                        Text("100").tag(100)
                        Text("بدون هدف").tag(0)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(15)
                .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                Button(role: .destructive) { showResetConfirmation = true } label: {
                    Label("تصفير العدّاد", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(.plain)
                .confirmationDialog("تصفير عدّاد السبحة؟", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                    Button("تصفير العدّاد الحالي", role: .destructive) { count = 0 }
                    Button("إلغاء", role: .cancel) { }
                } message: {
                    Text("سيبقى إجمالي التسبيحات المسجّل محفوظًا.")
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 22)
        }
    }

    private func increment() {
        count += 1
        total += 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if target > 0 && count % target == 0 {
            rounds += 1
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func stat(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 12)).foregroundStyle(.secondary)
            Text("\(value)").font(.system(size: 23, weight: .bold, design: .rounded).monospacedDigit()).foregroundStyle(Color.athkarInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

// MARK: - Settings

private struct SettingsView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var appIconManager: AppIconManager
    @State private var showIconMessage = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("إعدادات التطبيق")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.athkarInk)
                    Text("خصص التذكيرات والأيقونة لتناسبك.")
                        .font(.system(size: 13)).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 13) {
                    Label("التذكيرات اليومية", systemImage: "bell.badge.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.athkarInk)
                    Text(notificationManager.permissionDescription)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(notificationManager.isAuthorized ? Color.athkarGreen : Color.secondary)
                    Toggle("أذكار الصباح", isOn: $notificationManager.morningEnabled)
                        .tint(.athkarGreen)
                        .onChange(of: notificationManager.morningEnabled) { _, _ in saveNotificationPreferences() }
                    DatePicker("وقت الصباح", selection: $notificationManager.morningTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .onChange(of: notificationManager.morningTime) { _, _ in saveNotificationPreferences() }
                    Divider().overlay(Color.black.opacity(0.03))
                    Toggle("أذكار المساء", isOn: $notificationManager.eveningEnabled)
                        .tint(.athkarGreen)
                        .onChange(of: notificationManager.eveningEnabled) { _, _ in saveNotificationPreferences() }
                    DatePicker("وقت المساء", selection: $notificationManager.eveningTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .onChange(of: notificationManager.eveningTime) { _, _ in saveNotificationPreferences() }
                    Divider().overlay(Color.black.opacity(0.03))
                    Toggle("تذكير إضافي بالذكر", isOn: $notificationManager.middayEnabled)
                        .tint(.athkarGreen)
                        .onChange(of: notificationManager.middayEnabled) { _, _ in saveNotificationPreferences() }
                    if notificationManager.middayEnabled {
                        DatePicker("وقت التذكير", selection: $notificationManager.middayTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .onChange(of: notificationManager.middayTime) { _, _ in saveNotificationPreferences() }
                    }
                    Button {
                        Task { await notificationManager.requestPermissionAndSchedule() }
                    } label: {
                        Label(notificationManager.isAuthorized ? "حفظ وجدولة التذكيرات" : "تفعيل الإشعارات", systemImage: "bell.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(13)
                            .background(Color.athkarGreen, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    Button {
                        Task { await notificationManager.sendTestNotification() }
                    } label: {
                        Label("إرسال إشعار تجريبي بعد 5 ثوانٍ", systemImage: "paperplane")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.athkarGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                    }
                    .buttonStyle(.plain)
                    if let message = notificationManager.message {
                        Text(message).font(.system(size: 12)).foregroundStyle(.secondary).lineSpacing(3)
                    }
                }
                .padding(16)
                .background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                VStack(alignment: .leading, spacing: 13) {
                    Label("أيقونة التطبيق", systemImage: "app.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.athkarInk)
                    Text("اختر الشكل الذي يظهر على الشاشة الرئيسية. قد يعرض iOS رسالة تأكيد عند التغيير.")
                        .font(.system(size: 12)).foregroundStyle(.secondary).lineSpacing(3)
                    HStack(spacing: 10) {
                        ForEach(AthkarAppIcon.allCases) { icon in
                            Button {
                                Task {
                                    await appIconManager.setIcon(icon)
                                    showIconMessage = appIconManager.message != nil
                                }
                            } label: {
                                VStack(spacing: 9) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(LinearGradient(colors: [icon.color, icon.color.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        Image(systemName: icon.symbol)
                                            .font(.system(size: 27, weight: .medium))
                                            .foregroundStyle(.white)
                                        if appIconManager.isSelected(icon) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundStyle(.white)
                                                .background(icon.color, in: Circle())
                                                .offset(x: 26, y: -26)
                                        }
                                    }
                                    .frame(width: 75, height: 75)
                                    Text(icon.title)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(Color.athkarInk)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(appIconManager.isSelected(icon) ? Color.athkarGreen.opacity(0.08) : Color.clear,
                                            in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(appIconManager.isSelected(icon) ? Color.athkarGreen.opacity(0.55) : Color.black.opacity(0.05), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .disabled(appIconManager.isChanging)
                            .accessibilityLabel("اختيار أيقونة \(icon.title)")
                        }
                    }
                    if !appIconManager.supportsAlternateIcons {
                        Text("تغيير الأيقونة غير متاح في هذه البيئة.")
                            .font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                    if let message = appIconManager.message {
                        Text(message).font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                }
                .padding(16)
                .background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                VStack(alignment: .leading, spacing: 9) {
                    Label("الخصوصية", systemImage: "hand.raised.fill")
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(Color.athkarInk)
                    Text("يستخدم التطبيق موقعك أثناء الاستخدام لحساب اتجاه القبلة. الإحداثيات لا تُرسل إلى خادم بواسطة هذا المشروع. التذكيرات مجدولة محليًا عبر نظام iOS.")
                        .font(.system(size: 12)).foregroundStyle(.secondary).lineSpacing(4)
                }
                .padding(16)
                .background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                Text("Athkar · الإصدار 1.0")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 22)
        }
        .alert("أيقونة التطبيق", isPresented: $showIconMessage) {
            Button("حسنًا", role: .cancel) { }
        } message: {
            Text(appIconManager.message ?? "")
        }
    }

    private func saveNotificationPreferences() {
        Task { await notificationManager.persistAndSchedule() }
    }
}

// MARK: - Shared colors

extension Color {
    static let athkarGreen = Color(red: 0.17, green: 0.47, blue: 0.36)
    static let athkarDeepGreen = Color(red: 0.08, green: 0.29, blue: 0.25)
    static let athkarBlue = Color(red: 0.25, green: 0.52, blue: 0.72)
    static let athkarInk = Color(red: 0.10, green: 0.15, blue: 0.14)
    static let athkarBackground = Color(red: 0.94, green: 0.96, blue: 0.94)
}
