import WidgetKit
import SwiftUI

struct AffirmationEntry: TimelineEntry {
    let date: Date
    let message: String
}

struct AffirmationProvider: TimelineProvider {
    func placeholder(in context: Context) -> AffirmationEntry {
        AffirmationEntry(date: Date(), message: "I am good enough")
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (AffirmationEntry) -> Void) {
        let now = Date()
        completion(AffirmationEntry(date: now,
                                    message: Affirmations.affirmation(for: now)))
    }

    /// Build a timeline with one entry per day for the next 7 days so the
    /// message flips at local midnight without needing a background refresh.
    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        var entries: [AffirmationEntry] = []
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) else { continue }
            entries.append(AffirmationEntry(date: day,
                                            message: Affirmations.affirmation(for: day)))
        }

        let nextRefresh = calendar.date(byAdding: .day, value: 7, to: startOfToday) ?? Date().addingTimeInterval(86_400)
        completion(Timeline(entries: entries, policy: .after(nextRefresh)))
    }
}

/// Single-line Lock Screen widget that sits in the date slot above the clock.
/// iOS renders `.accessoryInline` as tinted monochrome text — no backgrounds,
/// colors or custom fonts are honoured, exactly like the stock "Mon Sep 29".
struct IAmWidgetEntryView: View {
    var entry: AffirmationEntry

    var body: some View {
        // iOS prepends the date automatically in the inline slot, so we
        // only emit the separator + affirmation: "- I am strong".
        Text("-  \(entry.message)")
            .widgetAccentable()
    }
}

struct IAmWorthyWidget: Widget {
    let kind: String = "IAmWorthyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AffirmationProvider()) { entry in
            IAmWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("I Am Worthy")
        .description("Replaces the Lock Screen date with a daily affirmation.")
        .supportedFamilies([.accessoryInline])
    }
}

#Preview(as: .accessoryInline) {
    IAmWorthyWidget()
} timeline: {
    AffirmationEntry(date: Date(), message: "I am good enough")
    AffirmationEntry(date: Date().addingTimeInterval(86_400), message: "I am strong")
}
