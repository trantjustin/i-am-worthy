import WidgetKit
import SwiftUI

struct WatchAffirmationEntry: TimelineEntry {
    let date: Date
    let message: String
}

struct WatchAffirmationProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchAffirmationEntry {
        WatchAffirmationEntry(date: Date(), message: "I am worthy")
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (WatchAffirmationEntry) -> Void) {
        let now = Date()
        completion(WatchAffirmationEntry(date: now,
                                         message: Affirmations.affirmation(for: now)))
    }

    /// Mirrors the iOS provider: 30 variable-length slots, deterministic from
    /// the date, so the watch and phone flip in lockstep without any sync code.
    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<WatchAffirmationEntry>) -> Void) {
        let now = Date()
        let slots = Affirmations.upcomingSlots(from: now, count: 30)
        let entries = slots.map {
            WatchAffirmationEntry(date: $0.start, message: $0.message)
        }
        let nextRefresh = slots.last?.end ?? now.addingTimeInterval(86_400)
        completion(Timeline(entries: entries, policy: .after(nextRefresh)))
    }
}

struct WatchAffirmationView: View {
    @Environment(\.widgetFamily) private var family
    var entry: WatchAffirmationEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            Text("-  \(entry.message)")
                .widgetAccentable()

        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Text(entry.message)
                    .font(.system(size: 11, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding(4)
            }
            .widgetAccentable()

        case .accessoryCorner:
            Text(entry.message)
                .font(.system(size: 12, weight: .semibold))
                .widgetAccentable()

        case .accessoryRectangular:
            Text(entry.message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .widgetAccentable()

        @unknown default:
            Text(entry.message)
        }
    }
}

struct IAmWorthyWatchWidget: Widget {
    let kind: String = "IAmWorthyWatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchAffirmationProvider()) { entry in
            WatchAffirmationView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("I Am Worthy!")
        .description("Daily affirmation on your watch face.")
        .supportedFamilies([
            .accessoryInline,
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular
        ])
    }
}

@main
struct IAmWorthyWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        IAmWorthyWatchWidget()
    }
}
