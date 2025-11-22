import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \UserSettings.createdAt) private var settings: [UserSettings]
    @State private var step: Step = .account
    @State private var selectedAuth: AuthMode = .iCloudUser
    @State private var selectedUnit: WeightUnit = .kg

    enum Step {
        case account
        case unit
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            switch step {
            case .account:
                VStack(spacing: 16) {
                    Text("Welcome")
                        .font(.largeTitle.bold())
                        .foregroundColor(AppTheme.text)
                    Button(action: {
                        selectedAuth = .iCloudUser
                        step = .unit
                    }) {
                        Text("Continue with iCloud")
                            .primaryButton()
                    }
                    Button(action: {
                        selectedAuth = .localOnly
                        step = .unit
                    }) {
                        Text("Continue without account")
                            .primaryButton()
                    }
                }
            case .unit:
                VStack(spacing: 16) {
                    Text("Choose your weight unit")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.text)
                    Picker("Unit", selection: $selectedUnit) {
                        Text("Kilograms (kg)").tag(WeightUnit.kg)
                        Text("Pounds (lb)").tag(WeightUnit.lb)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    Button(action: saveSettings) {
                        Text("Continue")
                            .primaryButton()
                    }
                }
            }
            Spacer()
        }
        .padding()
        .centeredFill()
        .animation(.easeInOut(duration: 0.15), value: step)
    }

    private func saveSettings() {
        let new = UserSettings(authMode: selectedAuth, weightUnit: selectedUnit, createdAt: .now, updatedAt: .now)
        context.insert(new)
    }
}
