import SwiftUI

struct ContentView: View {
    @State private var now = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                LockScreenPreview(date: now,
                                  message: Affirmations.affirmation(for: now))
                    .padding(.top, 16)

                VStack(alignment: .leading, spacing: 14) {
                    Label("How to set it up", systemImage: "lock.fill")
                        .font(.headline)

                    Text("I Am Worthy replaces the date on your iPhone Lock Screen with a short daily affirmation — a quiet reminder of your strength every time you glance at your phone. Each day brings a new message, automatically.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Long-press your Lock Screen", systemImage: "1.circle.fill")
                        Label("Tap Customize → Lock Screen", systemImage: "2.circle.fill")
                        Label("Tap the date above the clock", systemImage: "3.circle.fill")
                        Label("Select I Am from the widget list", systemImage: "4.circle.fill")
                        Label("Tap Done and enjoy!", systemImage: "5.circle.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Text("Your affirmation rotates daily — same message all day long.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Spacer()
            }
            .padding()
            .navigationTitle("I Am Worthy")
            .onReceive(timer) { now = $0 }
        }
    }
}

/// Mimics the Lock Screen date pill above the clock.
struct LockScreenPreview: View {
    let date: Date
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Text("\(Affirmations.dateHeader(for: date)) | \(message)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .background(Capsule().stroke(.white.opacity(0.4), lineWidth: 1))

            Text("11:15")
                .font(.system(size: 84, weight: .thin))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(colors: [.blue, .indigo, .black],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
}
