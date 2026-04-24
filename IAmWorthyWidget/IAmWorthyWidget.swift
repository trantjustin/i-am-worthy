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

    /// Build a timeline with one entry per 12-hour window for the next 7 days
    /// (14 entries) so the message flips at midnight and noon without a background refresh.
    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        let calendar = Calendar.current
        let now = Date()

        // Snap to the start of the current 12-hour window (midnight or noon local time).
        let startOfDay = calendar.startOfDay(for: now)
        let noon = startOfDay.addingTimeInterval(43_200)
        let windowStart = now >= noon ? noon : startOfDay

        var entries: [AffirmationEntry] = []
        for slotOffset in 0..<14 {
            let slot = windowStart.addingTimeInterval(Double(slotOffset) * 43_200)
            entries.append(AffirmationEntry(date: slot,
                                            message: Affirmations.affirmation(for: slot)))
        }

        let nextRefresh = windowStart.addingTimeInterval(14 * 43_200)
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
