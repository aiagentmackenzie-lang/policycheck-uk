import SwiftUI

struct ContentView: View {
    @State private var storage = StorageService()
    @State private var onboardingStep: Int = 0
    @State private var setupName: String = ""
    @State private var setupOrg: String = ""
    @State private var setupLOB: String = "All"
    @State private var setupSimulated: Bool = true
    @State private var setupApiKey: String = ""
    @State private var selectedTab: AppTab = .cases

    private enum AppTab: Hashable {
        case cases, newCase, history, settings
    }

    var body: some View {
        Group {
            if !storage.hasCompletedOnboarding {
                onboardingFlow
            } else {
                mainTabView
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var onboardingFlow: some View {
        switch onboardingStep {
        case 0:
            WelcomeView {
                withAnimation(.spring(duration: 0.4)) {
                    onboardingStep = 1
                }
            }
            .transition(.move(edge: .trailing))

        case 1:
            ProfileSetupView(
                name: $setupName,
                organisation: $setupOrg,
                lineOfBusiness: $setupLOB
            ) {
                withAnimation(.spring(duration: 0.4)) {
                    onboardingStep = 2
                }
            }
            .transition(.move(edge: .trailing))

        default:
            AnalysisModeView(
                useSimulated: $setupSimulated,
                apiKey: $setupApiKey
            ) {
                storage.settings.reviewerName = setupName
                storage.settings.organisation = setupOrg
                storage.settings.lineOfBusinessFocus = setupLOB
                storage.settings.useSimulatedData = setupSimulated
                storage.settings.openaiApiKey = setupApiKey
                storage.saveSettings()
                storage.completeOnboarding()
            }
            .transition(.move(edge: .trailing))
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            Tab("Cases", systemImage: "folder.fill", value: AppTab.cases) {
                CasesView(storage: storage)
            }

            Tab("New Case", systemImage: "plus.circle.fill", value: AppTab.newCase) {
                NewCaseView(storage: storage)
            }

            Tab("History", systemImage: "clock.fill", value: AppTab.history) {
                HistoryView(storage: storage)
            }

            Tab("Settings", systemImage: "gearshape.fill", value: AppTab.settings) {
                SettingsView(storage: storage)
            }
        }
        .tint(Theme.accent)
    }
}
