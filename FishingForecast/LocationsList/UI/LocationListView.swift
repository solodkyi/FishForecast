import SwiftUI

struct LocationListView: View {
    let cards: [LocationCard.Data]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(cards) { cardData in
                        LocationCard(cardData: cardData)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .navigationTitle("Fishing Spots")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .background(Color.gray.opacity(0.05))
        }
    }
}

struct LocationCard: View {
    struct Data: Identifiable {
        let id: UUID
        let name: String
        let weatherData: WeatherData?
    
        struct WeatherData { 
            let fishingScore: Int?
            let temperature: Int?
            let windSpeed: Double?
            let moonPhase: String?
        }
    }
    let cardData: Data
    
    private var cardGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                cardData.scoreColor.opacity(0.8),
                cardData.scoreColor.opacity(0.4)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(cardData.weatherData != nil ? cardGradient : LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Location name
                    Text(cardData.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    // Additional info
                    if let weather = cardData.weatherData {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                if let temperature = weather.temperature {
                                    Image(systemName: "thermometer")
                                        .foregroundColor(.secondary)
                                    Text("\(temperature)°C")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer().frame(width: 16)
                                }
                                
                                if let windSpeed = weather.windSpeed {
                                    Image(systemName: "wind")
                                        .foregroundColor(.secondary)
                                    Text("\(windSpeed, specifier: "%.1f") m/s")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if let moonPhase = weather.moonPhase {
                                HStack {
                                    Image(systemName: "moon.fill")
                                        .foregroundColor(.secondary)
                                    Text(moonPhase)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        Text("Weather data unavailable")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Fishing score badge
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                        
                        VStack(spacing: 2) {
                            if let fishingScore = cardData.weatherData?.fishingScore {
                                Text("\(fishingScore)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(cardData.scoreColor)
                                
                                Text("/ 10")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            } else {
                                Image(systemName: "questionmark")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Text(cardData.weatherData != nil ? "Fishing Score" : "No Data")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(20)
        }
        .frame(minHeight: 120)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle card tap - can navigate to detail view
        }
    }
}

#Preview {
    LocationListView(cards: FishingLocation.mocks.map(\.asLocationCardData))
}

extension LocationCard.Data {
     var scoreColor: Color {
        guard let score = weatherData?.fishingScore else { return Color.gray }
        
        switch score {
        case 0...2:
            return Color.red
        case 3...4:
            return Color.orange
        case 5...6:
            return Color.yellow
        case 7...8:
            return Color.green
        case 9...10:
            return Color.blue
        default:
            return Color.gray
        }
    }
}

fileprivate extension FishingLocation {
    var asLocationCardData: LocationCard.Data {
        if let forecast = forecast {
            return LocationCard.Data(
                id: id,
                name: name,
                weatherData: .init(
                    fishingScore: forecast.fishingScore,
                    temperature: Int(forecast.temperature),
                    windSpeed: forecast.windSpeed,
                    moonPhase: forecast.moonPhase.rawValue.capitalized
                )
            )
        } else {
            return LocationCard.Data(
                id: id,
                name: name,
                weatherData: nil
            )
        }
    }
}
