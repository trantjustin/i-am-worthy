import Foundation

/// Curated, built-in affirmations. Rotates once per day deterministically
/// so the widget and the app always show the same message on a given date.
public enum Affirmations {

    // Short affirmations curated / distilled from:
    //   https://livelovesimple.com/101-inspirational-quotes/
    //   https://www.briantracy.com/blog/personal-success/inspirational-quotes/
    // Kept deliberately short so the combined "Wed 22 Apr | <message>" fits
    // the .accessoryInline Lock Screen slot on iPhone 14 Pro (narrowest).
    public static let all: [String] = [
        // Fear / courage
        "I am not afraid",
        "I was born for this",
        "I act bravely",
        "I face the light",
        "I do it anyway",
        "I take the chance",
        "I am fearless",

        // Strength / resilience
        "I am strong",
        "I have a backbone",
        "I conquer myself",
        "I am unshaken",
        "I am resilient",
        "I rise again",
        "I keep going",

        // Self-worth
        "I am good enough",
        "I am enough",
        "I am worthy",
        "I am capable",
        "I am loved",
        "I am valued",
        "I deserve rest",
        "I take up space",

        // Happiness / mindset
        "I choose joy",
        "I choose peace",
        "I don't worry",
        "I adjust my sails",
        "I find solutions",
        "I am optimistic",

        // Presence
        "I live now",
        "I am present",
        "I am here",
        "I am calm",
        "I breathe deeply",

        // Gratitude / kindness
        "I am grateful",
        "I say thank you",
        "I see the miracle",
        "I am kind",
        "I speak kindly",
        "I heal with words",

        // Purpose
        "I come alive",
        "I enrich the world",
        "I have a song",
        "I live on purpose",

        // Hard work / discipline
        "I do the work",
        "I start now",
        "I stay consistent",
        "I finish strong",
        "I am disciplined",
        "I aim high",
        "I do what I can",

        // Growth / learning
        "I am learning",
        "I grow daily",
        "I unlearn and grow",
        "I embrace change",

        // Brian Tracy signatures
        "I can, I will",
        "I am a winner",
        "I like myself",
        "I am responsible",
        "I make it happen",
        "I set clear goals",
        "I move forward",

        // Success / outcome
        "I will succeed",
        "I am unstoppable",
        "I am confident",
        "I am focused",
        "I trust the process",
        "I am proud of me",
        "I am becoming",
        "I create my life"
    ]

    /// Deterministic selection based on the day of the Gregorian calendar.
    /// Same input date -> same affirmation across app + widget.
    public static func affirmation(for date: Date = Date(),
                                   calendar: Calendar = .current) -> String {
        let startOfDay = calendar.startOfDay(for: date)
        let days = Int(startOfDay.timeIntervalSinceReferenceDate / 86_400)
        let idx = ((days % all.count) + all.count) % all.count
        return all[idx]
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
