import Foundation

/// Curated, built-in affirmations. Rotates once per day deterministically
/// so the widget and the app always show the same message on a given date.
public enum Affirmations {

    // Short, generic inspirational / motivational phrases.
    // No attribution by design — these read as universal nudges rather than
    // quotations. Kept deliberately short (≤ 5 words / ~16 chars) so the
    // combined "Wed 22 Apr | <message>" fits the .accessoryInline Lock Screen
    // slot on iPhone 14 Pro (narrowest).
    public static let all: [String] = [
        // Courage / boldness
        "Be brave",
        "Be bold",
        "Be fearless",
        "Live boldly",
        "Take the leap",
        "Dare greatly",

        // Persistence
        "Never give up",
        "Keep going",
        "Press on",
        "Persist",
        "Onward",
        "Keep climbing",
        "Stay the course",

        // Action / starting
        "Just begin",
        "Begin now",
        "Do it now",
        "Show up",
        "Make it happen",
        "Make today count",

        // Strength
        "Stay strong",
        "Stand tall",
        "Rise up",
        "Rise and shine",

        // Mindset / joy
        "Choose joy",
        "Choose growth",
        "Find the joy",
        "Stay curious",
        "Stay hungry",
        "Dream big",
        "Keep dreaming",

        // Presence / authenticity
        "Be present",
        "Stay true",
        "Stay grounded",
        "Stay humble",
        "Stay focused",
        "Trust yourself",
        "Find your why",

        // Kindness / outward
        "Be kind",
        "Do good",
        "Lead with love",
        "Speak up",
        "Light the way",
        "Be the change",

        // Growth / outcome
        "Embrace change",
        "Aim high",
        "Shine bright",
        "Live fully",
        "Be unstoppable",
        "Less is more",
        "Carpe diem",

        // --- Additional phrases ---

        // Self-belief / voice
        "Believe in you",
        "You got this",
        "Trust your gut",
        "Own your story",
        "Find your voice",
        "Use your voice",
        "Speak truth",
        "Speak your truth",
        "Live your truth",
        "Walk your talk",
        "You matter",
        "Today matters",

        // More courage / momentum
        "Choose courage",
        "Step forward",
        "Move forward",
        "Forge ahead",
        "Push through",
        "Break through",
        "Hold the line",
        "Win the day",
        "Seize today",
        "Day by day",

        // More resilience
        "Try, try again",
        "Bend not break",
        "Begin again",
        "Start fresh",
        "Stay rooted",

        // More mindset / joy
        "Choose love",
        "Choose hope",
        "Choose kindness",
        "Choose patience",
        "Laugh often",
        "Smile more",
        "Be playful",
        "Spread joy",
        "Have fun",

        // More presence / calm
        "Stay calm",
        "Breathe deep",
        "Be still",
        "Slow down",
        "Let go",
        "Find balance",

        // More kindness / outward
        "Be the light",
        "Lift others up",
        "Sow kindness",
        "Listen well",
        "Plant seeds",

        // More growth
        "Grow daily",
        "Bloom now",
        "Heal and grow",

        // Classic "I am" affirmations
        "I am good enough",
        "I am strong",
        "I am enough",
        "I am worthy",
        "I am loved",
        "I am capable",
        "I am grateful",
        "I am calm",
        "I am brave",
        "I am here",
        "I am present",
        "I am fearless",
        "I am resilient",
        "I am confident",
        "I am at peace"
    ]

    // MARK: - Custom Quotes
    // Add your own affirmations here. Keep them short (≤ 5 words) to fit the Lock Screen slot.
    public static let customQuotes: [String] = [
        // "Your quote here",
        "I am proud"
    ]

    /// Combined pool used for selection — built-in quotes plus any custom ones.
    private static var pool: [String] {
        customQuotes.isEmpty ? all : all + customQuotes
    }

    public struct Slot {
        public let start: Date
        public let end: Date
        public let message: String
    }

    // Slot duration is uniformly random in [minSlot, maxSlot). Day-aligned so
    // the schedule is cheap to compute (no walk from epoch) but the user can't
    // predict when the affirmation will flip within the day.
    private static let minSlot: TimeInterval = 3_600        // 1 h
    private static let maxSlot: TimeInterval = 28_800       // 8 h
    private static let secondsPerDay: TimeInterval = 86_400

    /// Deterministic int mix — same inputs always produce same output across
    /// processes (Swift's `Hasher` is per-process randomized, so we can't use it).
    private static func mix(_ a: Int, _ b: Int) -> Int {
        // Compute in UInt64 so the constants don't overflow on 32-bit Int
        // platforms (e.g. arm64_32 watchOS).
        let ua = UInt64(bitPattern: Int64(a))
        let ub = UInt64(bitPattern: Int64(b))
        let h = (ua &* 1_000_003) ^ (ub &* 2_654_435_761)
        let mixed = (h &* 1_000_003) ^ 0x5555_5555
        return Int(truncatingIfNeeded: mixed)
    }

    /// All slots that fall within the local calendar day containing `date`.
    /// Slot lengths vary, so a day has between ~3 and ~24 slots; the final
    /// slot is clamped to midnight to keep day boundaries deterministic.
    private static func slotsInDay(containing date: Date,
                                   calendar: Calendar = .current) -> [Slot] {
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = dayStart.addingTimeInterval(secondsPerDay)
        let dayKey = Int(dayStart.timeIntervalSinceReferenceDate / secondsPerDay)
        let span = Int(maxSlot - minSlot)

        var result: [Slot] = []
        var cursor = dayStart
        var i = 0
        while cursor < dayEnd {
            let h = mix(dayKey, i)
            let dur = minSlot + TimeInterval(((h % span) + span) % span)
            let end = min(cursor.addingTimeInterval(dur), dayEnd)
            let idx = (((h / span) % pool.count) + pool.count) % pool.count
            result.append(Slot(start: cursor, end: end, message: pool[idx]))
            cursor = end
            i += 1
        }
        return result
    }

    /// The slot active at `date`. Same input date -> same slot across app + widget.
    public static func currentSlot(for date: Date = Date(),
                                   calendar: Calendar = .current) -> Slot {
        let slots = slotsInDay(containing: date, calendar: calendar)
        return slots.first(where: { date < $0.end }) ?? slots.last!
    }

    /// Convenience: just the message at `date`.
    public static func affirmation(for date: Date = Date()) -> String {
        currentSlot(for: date).message
    }

    /// Up to `count` slots starting at or covering `date`, walking forward
    /// across day boundaries. Used by `TimelineProvider` to pre-bake entries.
    public static func upcomingSlots(from date: Date = Date(),
                                     count: Int,
                                     calendar: Calendar = .current) -> [Slot] {
        var result: [Slot] = []
        var dayCursor = calendar.startOfDay(for: date)
        while result.count < count {
            for slot in slotsInDay(containing: dayCursor, calendar: calendar) where slot.end > date {
                result.append(slot)
                if result.count >= count { return result }
            }
            dayCursor = dayCursor.addingTimeInterval(secondsPerDay)
        }
        return result
    }

    /// Header like "Wed 22 Apr" matching iOS Calendar widget styling.
    public static func dateHeader(for date: Date = Date(),
                                  locale: Locale = .current) -> String {
        let f = DateFormatter()
        f.locale = locale
        f.setLocalizedDateFormatFromTemplate("EEE d MMM")
        return f.string(from: date)
    }
}
