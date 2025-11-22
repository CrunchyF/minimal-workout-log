import SwiftUI
import SwiftData

struct WorkoutSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State var session: WorkoutSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Summary")
                    .font(.largeTitle.bold())
                    .foregroundColor(AppTheme.text)
                metrics
                bestSet
                volumeBreakdown
                notes
                moodPicker
                if hasChanges {
                    Button("Review changes", action: {})
                        .primaryButton()
                }
            }
            .padding()
        }
        .background(AppTheme.background)
    }

    private var metrics: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total session time: \(sessionDuration())")
                .foregroundColor(AppTheme.text)
            Text("Estimated work time: \(session.totalSets * 40) sec")
                .mutedText()
            Text("Total weight lifted: \(Int(session.totalWeightLifted))")
                .foregroundColor(AppTheme.text)
            Text("Total sets: \(session.totalSets)")
                .foregroundColor(AppTheme.text)
        }
    }

    private var bestSet: some View {
        let best = session.exercises.flatMap { $0.sets }.max { lhs, rhs in
            (Double(lhs.reps) * lhs.weight) < (Double(rhs.reps) * rhs.weight)
        }
        return VStack(alignment: .leading, spacing: 8) {
            if let best = best, let exercise = session.exercises.first(where: { $0.sets.contains(where: { $0.id == best.id }) }) {
                Text("Best Set: \(exercise.name) — \(best.reps) × \(Int(best.weight))")
                    .foregroundColor(AppTheme.text)
            }
        }
    }

    private var volumeBreakdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(session.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { exercise in
                let volume = exercise.sets.reduce(0) { $0 + (Double($1.reps) * $1.weight) }
                Text("\(exercise.name) — \(exercise.sets.count) sets — \(Int(volume)) total volume")
                    .foregroundColor(AppTheme.text)
            }
        }
    }

    private var notes: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Notes today:")
                .mutedText()
            ForEach(session.exercises) { exercise in
                if let note = exercise.notes, !note.isEmpty {
                    Text("\(exercise.name): \(note)")
                        .foregroundColor(AppTheme.text)
                }
            }
        }
    }

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How was it?")
                .foregroundColor(AppTheme.text)
            HStack {
                ForEach(SessionMood.allCases) { mood in
                    Button(mood.rawValue.capitalized) {
                        session.mood = mood
                        try? context.save()
                    }
                    .primaryButton()
                }
            }
        }
    }

    private var hasChanges: Bool {
        session.exercises.contains { $0.origin != .fromTemplate }
    }

    private func sessionDuration() -> String {
        guard let end = session.endTime else { return "--" }
        let diff = Int(end.timeIntervalSince(session.startTime))
        return "\(diff / 60) min"
    }
}
