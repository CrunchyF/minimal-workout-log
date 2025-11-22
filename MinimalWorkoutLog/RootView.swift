import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \UserSettings.createdAt) private var settings: [UserSettings]
    @State private var showingOnboarding = false

    var body: some View {
        Group {
            if let settings = settings.first {
                MainContainerView(settings: settings)
            } else {
                OnboardingFlow()
            }
        }
        .onAppear {
            ensureSettings()
        }
    }

    private func ensureSettings() {
        if settings.isEmpty {
            let defaults = UserSettings()
            context.insert(defaults)
        }
    }
}

struct MainContainerView: View {
    @Environment(\.modelContext) private var context
    @State private var path = NavigationPath()
    let settings: UserSettings

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(settings: settings) { destination in
                path.append(destination)
            }
            .navigationDestination(for: NavigationTarget.self) { target in
                switch target {
                case .templateCreation:
                    TemplateCreationView()
                case .stats:
                    StatsView()
                case .settings:
                    SettingsView(settings: settings)
                case .workout(let template):
                    WorkoutExecutionView(template: template)
                case .summary(let session):
                    WorkoutSummaryView(session: session)
                }
            }
        }
    }
}

enum NavigationTarget: Hashable {
    case templateCreation
    case stats
    case settings
    case workout(WorkoutTemplate)
    case summary(WorkoutSession)
}
