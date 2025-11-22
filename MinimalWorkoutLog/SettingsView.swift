import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @State var settings: UserSettings

    var body: some View {
        Form {
            Section("Units") {
                Picker("Weight", selection: $settings.weightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.rawValue.uppercased()).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: settings.weightUnit) { _, _ in settings.updatedAt = .now }
            }
            Section("Account / Sync") {
                if settings.authMode == .localOnly {
                    Button("Connect iCloud") {
                        settings.authMode = .iCloudUser
                        settings.updatedAt = .now
                    }
                } else {
                    Text("iCloud backup enabled")
                }
            }
            Section("About") {
                VStack(alignment: .leading) {
                    Text("Minimal Workout Log")
                    Text("Version 1.0")
                        .font(.footnote)
                        .mutedText()
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .onChange(of: settings.authMode) { _, _ in try? context.save() }
        .onChange(of: settings.weightUnit) { _, _ in try? context.save() }
    }
}
