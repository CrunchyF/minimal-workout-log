import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<WorkoutTemplate> { !$0.isArchived }, sort: \WorkoutTemplate.createdAt, animation: .smooth) private var templates: [WorkoutTemplate]
    let settings: UserSettings
    var navigate: (NavigationTarget) -> Void
    @State private var isScrolling = false

    var body: some View {
        VStack(spacing: 24) {
            Button("Stats") { navigate(.stats) }
                .mutedText()
            Text("Workouts")
                .font(.largeTitle.bold())
                .foregroundColor(AppTheme.text)
                .opacity(isScrolling ? 0.7 : 1)
                .scaleEffect(isScrolling ? 0.95 : 1)
            templateList
            Button(action: { navigate(.templateCreation) }) {
                Text("+")
                    .font(.largeTitle.bold())
                    .primaryButton()
            }
            Spacer()
            Button(action: { navigate(.settings) }) {
                Image(systemName: "gearshape")
                    .foregroundColor(AppTheme.text)
                    .font(.title2)
            }
        }
        .padding()
        .centeredFill()
    }

    private var templateList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(templates.prefix(3)) { template in
                    Button {
                        navigate(.workout(template))
                    } label: {
                        VStack(alignment: .center) {
                            Text(template.name)
                                .font(.headline)
                                .foregroundColor(AppTheme.text)
                            Text("\(template.exercises.count) exercises")
                                .mutedText()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.purple.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            .padding(.vertical)
        }
        .frame(maxHeight: 240)
        .scaleEffect(isScrolling ? 1.02 : 1)
        .opacity(isScrolling ? 0.95 : 1)
        .gesture(DragGesture().onChanged { _ in isScrolling = true }.onEnded { _ in isScrolling = false })
    }
}
