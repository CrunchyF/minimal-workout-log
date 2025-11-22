import SwiftUI
import SwiftData

struct WorkoutExecutionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutSession.startTime, order: .reverse) private var sessions: [WorkoutSession]
    let template: WorkoutTemplate
    @State private var workout: WorkoutSession
    @State private var currentExerciseIndex: Int = 0
    @State private var reps: String = ""
    @State private var weight: String = ""
    @State private var showingNotes = false

    init(template: WorkoutTemplate) {
        self.template = template
        _workout = State(initialValue: WorkoutSession(template: template))
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            lastTimeView
            mainInputs
            todayList
            Button("Notes") { showingNotes = true }
                .mutedText()
            nextPreview
            bottomButtons
        }
        .padding()
        .centeredFill()
        .sheet(isPresented: $showingNotes) {
            notesEditor
        }
    }

    private var currentTemplateExercise: TemplateExercise? {
        guard currentExerciseIndex < template.exercises.count else { return nil }
        return template.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })[currentExerciseIndex]
    }

    private var currentExerciseSession: ExerciseSession {
        if let existing = workout.exercises.first(where: { $0.orderIndex == currentExerciseIndex }) {
            return existing
        }
        let new = ExerciseSession(workout: workout, templateExercise: currentTemplateExercise, name: currentTemplateExercise?.name ?? "Exercise", orderIndex: currentExerciseIndex, origin: .fromTemplate)
        workout.exercises.append(new)
        return new
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(currentExerciseSession.name) — Set \(currentExerciseSession.sets.count + 1) of \(currentTemplateExercise?.plannedSets ?? currentExerciseSession.sets.count + 1)")
                    .font(.headline)
                    .foregroundColor(AppTheme.text)
                if currentExerciseSession.sets.isEmpty {
                    Button("Swap") {
                        swapExercise()
                    }
                    .mutedText()
                }
            }
            Spacer()
        }
    }

    private var lastTimeView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Last time")
                .mutedText()
            let previousSets = previousExerciseSets()
            if previousSets.isEmpty {
                Text("No history")
                    .mutedText()
            } else {
                ForEach(Array(previousSets.enumerated()), id: \.(0)) { index, set in
                    Text("Set \(index + 1) — \(set.reps) × \(Int(set.weight))")
                        .mutedText()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mainInputs: some View {
        VStack(spacing: 12) {
            TextField("Reps", text: $reps)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            TextField("Weight", text: $weight)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
            Button("Log Set", action: logSet)
                .primaryButton()
        }
    }

    private var todayList: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today")
                .mutedText()
            ForEach(currentExerciseSession.sets.sorted(by: { $0.setIndex < $1.setIndex })) { set in
                Text("Set \(set.setIndex) — \(set.reps) × \(Int(set.weight))")
                    .foregroundColor(set.isExtra ? AppTheme.purple : AppTheme.text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var nextPreview: some View {
        let nextIndex = currentExerciseIndex + 1
        let nextName = nextIndex < template.exercises.count ? template.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })[nextIndex].name : "Finish"
        return Text("Next: \(nextName)")
            .mutedText()
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            Button("END WORKOUT") { endWorkout(force: true) }
                .primaryButton()
            Button("Squeeze one in") { squeezeExercise() }
                .primaryButton()
            Button("NEXT EXERCISE") { moveToNextExercise() }
                .primaryButton()
        }
    }

    private var notesEditor: some View {
        NavigationStack {
            VStack {
                TextEditor(text: Binding(get: { currentExerciseSession.notes ?? "" }, set: { currentExerciseSession.notes = $0 }))
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Spacer()
            }
            .padding()
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showingNotes = false }
                }
            }
        }
    }

    private func logSet() {
        guard let repsValue = Int(reps), let weightValue = Double(weight) else { return }
        let setIndex = currentExerciseSession.sets.count + 1
        let isExtra = setIndex > (currentTemplateExercise?.plannedSets ?? setIndex)
        let newSet = WorkoutSet(exerciseSession: currentExerciseSession, setIndex: setIndex, reps: repsValue, weight: weightValue, isExtra: isExtra)
        currentExerciseSession.sets.append(newSet)
        reps = ""
        weight = weight.isEmpty ? weight : weight
    }

    private func moveToNextExercise() {
        if currentExerciseIndex + 1 < template.exercises.count {
            currentExerciseIndex += 1
        } else {
            endWorkout(force: false)
        }
    }

    private func squeezeExercise() {
        let newIndex = currentExerciseIndex + 1
        let exercise = ExerciseSession(workout: workout, templateExercise: nil, name: "Custom", orderIndex: newIndex, origin: .squeezedIn)
        workout.exercises.insert(exercise, at: min(newIndex, workout.exercises.count))
    }

    private func swapExercise() {
        let replacement = ExerciseSession(workout: workout, templateExercise: nil, name: "Swapped", orderIndex: currentExerciseIndex, origin: .swappedIn)
        if let idx = workout.exercises.firstIndex(where: { $0.orderIndex == currentExerciseIndex }) {
            workout.exercises[idx] = replacement
        } else {
            workout.exercises.append(replacement)
        }
    }

    private func endWorkout(force: Bool) {
        workout.endTime = .now
        workout.totalSets = workout.exercises.reduce(0) { $0 + $1.sets.count }
        workout.totalWeightLifted = workout.exercises.flatMap { $0.sets }.reduce(0) { $0 + (Double($1.reps) * $1.weight) }
        context.insert(workout)
        dismiss()
    }

    private func previousExerciseSets() -> [WorkoutSet] {
        guard let previous = sessions.first(where: { $0.template?.id == template.id }) else { return [] }
        let templateExercises = template.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })
        guard currentExerciseIndex < templateExercises.count else { return [] }
        let targetName = templateExercises[currentExerciseIndex].name
        return previous.exercises.first(where: { $0.name == targetName })?.sets ?? []
    }
}
