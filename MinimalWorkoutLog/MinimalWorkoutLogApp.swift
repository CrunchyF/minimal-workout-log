import SwiftUI
import SwiftData

@main
struct MinimalWorkoutLogApp: App {
    @State private var container: ModelContainer? = try? ModelContainer(for: UserSettings.self, WorkoutTemplate.self, TemplateExercise.self, WorkoutSession.self, ExerciseSession.self, WorkoutSet.self, configurations: ModelConfiguration(cloudKitDatabase: .automatic))

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container!)
        }
        .modelContainer(container!)
    }
}
