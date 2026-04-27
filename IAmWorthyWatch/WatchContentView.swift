import SwiftUI

struct WatchContentView: View {
    @State private var now = Date()

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(Affirmations.affirmation(for: now))
            .font(.title2)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 8)
        .containerBackground(.fill.tertiary, for: .navigation)
        .onReceive(timer) { now = $0 }
    }
}

#Preview {
    WatchContentView()
}
