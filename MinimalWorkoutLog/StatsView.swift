import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    var body: some View {
        List {
            Section("Stats") {
                ForEach(sessions) { session in
                    NavigationLink(destination: WorkoutSummaryView(session: session)) {
                        VStack(alignment: .leading) {
                            Text(session.date.formatted(date: .abbreviated, time: .shortened))
                            Text(session.template?.name ?? "Untitled")
                                .mutedText()
                            Text("Total weight: \(Int(session.totalWeightLifted))")
                                .font(.footnote)
                                .foregroundColor(AppTheme.text)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
    }
}
