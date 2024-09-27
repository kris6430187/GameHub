import WidgetKit
import SwiftUI

struct GameDeal: Codable {
    let title: String
    let salePrice: String
    let normalPrice: String
    let thumb: String
    let storeID: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), deal: GameDeal(title: "Loading...", salePrice: "0.00", normalPrice: "0.00", thumb: "", storeID: ""))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), deal: GameDeal(title: "Sample Game", salePrice: "9.99", normalPrice: "19.99", thumb: "", storeID: "1"))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task {
            let deal = await fetchRandomDeal()
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            let entry = SimpleEntry(date: currentDate, deal: deal)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }

    private func fetchRandomDeal() async -> GameDeal {
        guard let url = URL(string: "https://www.cheapshark.com/api/1.0/deals?sortBy=Price&desc=0&onSale=1&pageSize=60") else {
            return GameDeal(title: "Error", salePrice: "0.00", normalPrice: "0.00", thumb: "", storeID: "")
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let deals = try JSONDecoder().decode([GameDeal].self, from: data)
            return deals.randomElement() ?? GameDeal(title: "No deals found", salePrice: "0.00", normalPrice: "0.00", thumb: "", storeID: "")
        } catch {
            return GameDeal(title: "Error fetching", salePrice: "0.00", normalPrice: "0.00", thumb: "", storeID: "")
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let deal: GameDeal
}

struct GameHubDealsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let url = URL(string: entry.deal.thumb),
               let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 100)
                    .cornerRadius(8)
            } else {
                Color.gray.opacity(0.3)
                    .frame(maxHeight: 100)
                    .cornerRadius(8)
            }
            
            Text(entry.deal.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            HStack {
                Text("Sale: $\(entry.deal.salePrice)")
                    .foregroundColor(.green)
                    .fontWeight(.bold)
                Text("Was: $\(entry.deal.normalPrice)")
                    .strikethrough()
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(UIColor.systemBackground).opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct GameHubDeals: Widget {
    let kind: String = "GameHubDeals"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GameHubDealsEntryView(entry: entry)
        }
        .configurationDisplayName("Game Deals")
        .description("Shows a random game deal.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
