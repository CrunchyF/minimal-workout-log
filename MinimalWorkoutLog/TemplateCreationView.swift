import SwiftUI
import SwiftData

struct TemplateCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var templateName: String = ""
    @State private var exercises: [TemplateExercise] = []
    @State private var step: Step = .name
    @State private var currentName: String = ""
    @State private var currentSets: Int = 3
    @State private var rangeMin: Int = 8
    @State private var rangeMax: Int = 12

    enum Step {
        case name
        case sets
        case reps
    }

    var body: some View {
        VStack(spacing: 16) {
            Button("Back") { dismiss() }
                .mutedText()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { ex in
                        Text("\(ex.name) — \(ex.plannedSets) sets" + (ex.repRangeMin != nil ? " — \(ex.repRangeMin ?? 0)-\(ex.repRangeMax ?? 0) reps" : ""))
                            .foregroundColor(AppTheme.text)
                    }
                }
            }
            Spacer()
            stepContent
            Spacer()
            Button(action: finalizeTemplate) {
                Text("Done")
                    .primaryButton()
            }
            .disabled(exercises.isEmpty)
            .opacity(exercises.isEmpty ? 0.5 : 1)
        }
        .padding()
        .centeredFill()
        .animation(.easeInOut(duration: 0.15), value: step)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .name:
            VStack(spacing: 12) {
                Text("Name the exercise")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.text)
                TextField("Exercise", text: $currentName)
                    .textFieldStyle(.roundedBorder)
                Button("Next") { step = .sets }
                    .primaryButton()
                    .disabled(currentName.isEmpty)
                    .opacity(currentName.isEmpty ? 0.5 : 1)
            }
        case .sets:
            VStack(spacing: 12) {
                Text("How many sets?")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.text)
                Stepper("\(currentSets) sets", value: $currentSets, in: 1...10)
                    .foregroundColor(AppTheme.text)
                Button("Next") { step = .reps }
                    .primaryButton()
            }
        case .reps:
            VStack(spacing: 12) {
                Text("Suggested rep range (optional)")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.text)
                HStack {
                    TextField("From", value: $rangeMin, format: .number)
                        .textFieldStyle(.roundedBorder)
                    TextField("To", value: $rangeMax, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                HStack(spacing: 12) {
                    Button("Skip") { appendExercise(repMin: nil, repMax: nil) }
                        .primaryButton()
                    Button("Next") { appendExercise(repMin: rangeMin, repMax: rangeMax) }
                        .primaryButton()
                }
            }
        }
    }

    private func appendExercise(repMin: Int?, repMax: Int?) {
        let exercise = TemplateExercise(name: currentName, orderIndex: exercises.count, plannedSets: currentSets, repRangeMin: repMin, repRangeMax: repMax)
        exercises.append(exercise)
        currentName = ""
        currentSets = 3
        rangeMin = 8
        rangeMax = 12
        step = .name
    }

    private func finalizeTemplate() {
        guard !exercises.isEmpty else { return }
        let template = WorkoutTemplate(name: templateName.isEmpty ? "New Template" : templateName, exercises: exercises)
        exercises.forEach { $0.parentTemplate = template }
        context.insert(template)
        dismiss()
    }
}
