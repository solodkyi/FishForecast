import Foundation

struct FishingLocation: Identifiable, Equatable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let forecast: FishingForecastInput?
} 

struct FishingForecastInput: Equatable {
    // MARK: - Weather Data
    let temperature: Double             // °C
    let pressure: Double                // hPa
    let pressureTrend: PressureTrend
    let windSpeed: Double               // m/s
    let cloudCover: Double              // 0.0 to 1.0
    
    // MARK: - Time Info
    let currentTime: Date
    let sunrise: Date
    let sunset: Date
    
    // MARK: - Lunar Info
    let moonPhase: MoonPhase
    let majorPeriods: [ClosedRange<Date>]
    let minorPeriods: [ClosedRange<Date>]
    
    enum PressureTrend {
        case rising
        case falling
        case steady
    }
    
    enum MoonPhase: String {
        case new, waxingCrescent, firstQuarter, waxingGibbous
        case full, waningGibbous, lastQuarter, waningCrescent
        
        var strength: Double {
            switch self {
            case .full, .new: return 1.0
            case .firstQuarter, .lastQuarter: return 0.5
            default: return 0.75
            }
        }
    }
}

extension FishingForecastInput {
    var fishingScore: Int {
        var score = 0.0

        // 1. Moon phase strength
        score += moonPhase.strength * 2.0

        // 2. Check if currently in major/minor period
        let isActivePeriod = majorPeriods.contains { $0.contains(currentTime) } ||
                             minorPeriods.contains { $0.contains(currentTime) }
        if isActivePeriod { score += 2.0 }

        // 3. Sunrise/sunset proximity bonus (±30 minutes)
        let margin: TimeInterval = 30 * 60
        if abs(currentTime.timeIntervalSince(sunrise)) <= margin ||
            abs(currentTime.timeIntervalSince(sunset)) <= margin {
            score += 1.0
        }

        // 4. Barometric pressure trend
        switch pressureTrend {
        case .rising: score += 1.0
        case .steady: score += 0.5
        case .falling: break
        }

        // 5. Wind: light to moderate is good (e.g. 2–5 m/s)
        if windSpeed >= 1.5 && windSpeed <= 5.0 {
            score += 1.0
        }

        // 6. Cloud cover: slight overcast is good
        if cloudCover >= 0.3 && cloudCover <= 0.7 {
            score += 1.0
        }

        // 7. Temperature within optimal fishing comfort range (10–25°C)
        if (10...25).contains(temperature) {
            score += 1.0
        }

        return Int(score.rounded(.toNearestOrAwayFromZero)).clamped(to: 0...10)
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension FishingLocation {
    static var mocks: [FishingLocation] = [
        FishingLocation(
            id: UUID(),
            name: "Lake Tahoe",
            latitude: 39.0968,
            longitude: -120.0324,
            forecast: FishingForecastInput(
                temperature: 18.0,
                pressure: 1013.25,
                pressureTrend: .rising,
                windSpeed: 3.2,
                cloudCover: 0.4,
                currentTime: Date(),
                sunrise: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                sunset: Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date(),
                moonPhase: .full,
                majorPeriods: [],
                minorPeriods: []
            )
        ),
        FishingLocation(
            id: UUID(),
            name: "San Francisco Bay",
            latitude: 37.8270,
            longitude: -122.4230,
            forecast: FishingForecastInput(
                temperature: 15.5,
                pressure: 1020.1,
                pressureTrend: .steady,
                windSpeed: 6.8,
                cloudCover: 0.2,
                currentTime: Date(),
                sunrise: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
                sunset: Calendar.current.date(byAdding: .hour, value: 7, to: Date()) ?? Date(),
                moonPhase: .waxingGibbous,
                majorPeriods: [],
                minorPeriods: []
            )
        ),
        FishingLocation(
            id: UUID(),
            name: "Monterey Bay",
            latitude: 36.6002,
            longitude: -121.8947,
            forecast: FishingForecastInput(
                temperature: 16.8,
                pressure: 1015.3,
                pressureTrend: .falling,
                windSpeed: 2.1,
                cloudCover: 0.6,
                currentTime: Date(),
                sunrise: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
                sunset: Calendar.current.date(byAdding: .hour, value: 9, to: Date()) ?? Date(),
                moonPhase: .new,
                majorPeriods: [],
                minorPeriods: []
            )
        ),
        FishingLocation(
            id: UUID(),
            name: "Big Sur Coast",
            latitude: 36.2704,
            longitude: -121.8081,
            forecast: nil
        )
    ]
}
