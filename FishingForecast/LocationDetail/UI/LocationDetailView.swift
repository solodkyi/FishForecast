import SwiftUI
import MapKit

struct LocationDetailView: View {
    struct Data: Identifiable {
        let id: UUID
        let name: String
        let latitude: Double
        let longitude: Double
        let forecast: ForecastData?
        let scoreColor: Color
        
        struct ForecastData {
            let fishingScore: Int
            let temperature: Double
            let pressure: Double
            let pressureTrend: FishingForecastInput.PressureTrend
            let windSpeed: Double
            let cloudCover: Double
            let currentTime: Date
            let sunrise: Date
            let sunset: Date
            let moonPhase: FishingForecastInput.MoonPhase
        }
    }
    
    let data: Data
    
    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: data.latitude,
                longitude: data.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
    
    private var cardGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                data.scoreColor.opacity(0.8),
                data.scoreColor.opacity(0.4)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MapSection(data: data, region: region)
                
                FishingScoreCard(
                    forecast: data.forecast,
                    scoreColor: data.scoreColor,
                    cardGradient: cardGradient
                )
                
                if let forecast = data.forecast {
                    WeatherDetailsCard(forecast: forecast)
                    
                    FishingConditionsCard(forecast: forecast)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .navigationTitle(data.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .background(Color.gray.opacity(0.05))
    }
}

struct MapSection: View {
    let data: LocationDetailView.Data
    let region: MKCoordinateRegion
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 0) {
                Map {
                    Marker("", coordinate: CLLocationCoordinate2D(
                        latitude: data.latitude,
                        longitude: data.longitude
                    ))
                    .tint(.blue)
                }
                .mapStyle(.standard)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(16)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.4f°, %.4f°", data.latitude, data.longitude))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(height: 280)
    }
}

struct FishingScoreCard: View {
    let forecast: LocationDetailView.Data.ForecastData?
    let scoreColor: Color
    let cardGradient: LinearGradient
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(forecast != nil ? cardGradient : LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fishing Score")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let forecast = forecast {
                        Text(scoreDescription(for: forecast.fishingScore))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Weather data unavailable")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    
                    VStack(spacing: 2) {
                        if let fishingScore = forecast?.fishingScore {
                            Text("\(fishingScore)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(scoreColor)
                            
                            Text("/ 10")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        } else {
                            Image(systemName: "questionmark")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(24)
        }
        .frame(minHeight: 120)
    }
    
    private func scoreDescription(for score: Int) -> String {
        switch score {
        case 0...2:
            return "Poor fishing conditions"
        case 3...4:
            return "Fair fishing conditions"
        case 5...6:
            return "Good fishing conditions"
        case 7...8:
            return "Great fishing conditions"
        case 9...10:
            return "Excellent fishing conditions"
        default:
            return "Unknown conditions"
        }
    }
}

struct WeatherDetailsCard: View {
    let forecast: LocationDetailView.Data.ForecastData
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Weather Details")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    WeatherDetailItem(
                        icon: "thermometer",
                        title: "Temperature",
                        value: "\(Int(forecast.temperature))°C"
                    )
                    
                    WeatherDetailItem(
                        icon: "wind",
                        title: "Wind Speed",
                        value: String(format: "%.1f m/s", forecast.windSpeed)
                    )
                    
                    WeatherDetailItem(
                        icon: "barometer",
                        title: "Pressure",
                        value: String(format: "%.1f hPa", forecast.pressure)
                    )
                    
                    WeatherDetailItem(
                        icon: "cloud.fill",
                        title: "Cloud Cover",
                        value: "\(Int(forecast.cloudCover * 100))%"
                    )
                }
            }
            .padding(20)
        }
    }
}

struct WeatherDetailItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FishingConditionsCard: View {
    let forecast: LocationDetailView.Data.ForecastData
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Fishing Conditions")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    FishingConditionRow(
                        icon: "moon.fill",
                        title: "Moon Phase",
                        value: forecast.moonPhase.rawValue.capitalized
                    )
                    
                    FishingConditionRow(
                        icon: "arrow.up.arrow.down",
                        title: "Pressure Trend",
                        value: pressureTrendText(forecast.pressureTrend)
                    )
                    
                    FishingConditionRow(
                        icon: "sunrise",
                        title: "Sunrise",
                        value: DateFormatter.timeFormatter.string(from: forecast.sunrise)
                    )
                    
                    FishingConditionRow(
                        icon: "sunset",
                        title: "Sunset",
                        value: DateFormatter.timeFormatter.string(from: forecast.sunset)
                    )
                }
            }
            .padding(20)
        }
    }
    
    private func pressureTrendText(_ trend: FishingForecastInput.PressureTrend) -> String {
        switch trend {
        case .rising:
            return "Rising"
        case .falling:
            return "Falling"
        case .steady:
            return "Steady"
        }
    }
}

struct FishingConditionRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

private extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

fileprivate extension FishingLocation {
    var asLocationDetailData: LocationDetailView.Data {
        if let forecast = forecast {
            return LocationDetailView.Data(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                forecast: .init(
                    fishingScore: forecast.fishingScore,
                    temperature: forecast.temperature,
                    pressure: forecast.pressure,
                    pressureTrend: forecast.pressureTrend,
                    windSpeed: forecast.windSpeed,
                    cloudCover: forecast.cloudCover,
                    currentTime: forecast.currentTime,
                    sunrise: forecast.sunrise,
                    sunset: forecast.sunset,
                    moonPhase: forecast.moonPhase
                ),
                scoreColor: scoreColor
            )
        } else {
            return LocationDetailView.Data(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                forecast: nil,
                scoreColor: scoreColor
            )
        }
    }
}

#Preview {
    NavigationView {
        LocationDetailView(data: FishingLocation.mocks[2].asLocationDetailData)
    }
}
