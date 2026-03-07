import SwiftUI

struct SettingsView: View {
    let storage: StorageService
    @State private var showClearConfirmation: Bool = false
    @State private var showApiKey: Bool = false
    @State private var hapticTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        profileSection
                        analysisEngineSection
                        dataPrivacySection
                        aboutSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Clear All Cases", isPresented: $showClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    storage.clearAllCases()
                    hapticTrigger.toggle()
                }
            } message: {
                Text("This will permanently delete all cases. This action cannot be undone.")
            }
            .sensoryFeedback(.warning, trigger: hapticTrigger)
        }
    }

    private var profileSection: some View {
        SettingsSection(title: "Profile", icon: "person.fill") {
            VStack(spacing: 12) {
                SettingsTextField(label: "Your Name", text: Binding(
                    get: { storage.settings.reviewerName },
                    set: { storage.settings.reviewerName = $0; storage.saveSettings() }
                ))

                SettingsTextField(label: "Organisation", text: Binding(
                    get: { storage.settings.organisation },
                    set: { storage.settings.organisation = $0; storage.saveSettings() }
                ))

                VStack(alignment: .leading, spacing: 6) {
                    Text("Line of Business Focus")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(["Property", "Motor", "Liability", "Life", "All"], id: \.self) { option in
                                Button {
                                    storage.settings.lineOfBusinessFocus = option
                                    storage.saveSettings()
                                } label: {
                                    Text(option)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(storage.settings.lineOfBusinessFocus == option ? .white : Theme.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(storage.settings.lineOfBusinessFocus == option ? Theme.accent : Theme.background)
                                        .clipShape(.rect(cornerRadius: 6))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var analysisEngineSection: some View {
        SettingsSection(title: "Analysis Engine", icon: "cpu") {
            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Use Simulated Analysis")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textPrimary)
                        Text("Mock responses for testing")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { storage.settings.useSimulatedData },
                        set: { storage.settings.useSimulatedData = $0; storage.saveSettings() }
                    ))
                    .tint(Theme.accent)
                }

                Rectangle()
                    .fill(Theme.surfaceBorder)
                    .frame(height: 1)

                VStack(alignment: .leading, spacing: 6) {
                    Text("OpenAI API Key")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.textSecondary)

                    HStack {
                        if showApiKey {
                            TextField("", text: Binding(
                                get: { storage.settings.openaiApiKey },
                                set: { storage.settings.openaiApiKey = $0; storage.saveSettings() }
                            ), prompt: Text("sk-...").foregroundStyle(Theme.textSecondary.opacity(0.5)))
                            .font(.caption)
                            .foregroundStyle(Theme.textPrimary)
                        } else {
                            SecureField("", text: Binding(
                                get: { storage.settings.openaiApiKey },
                                set: { storage.settings.openaiApiKey = $0; storage.saveSettings() }
                            ), prompt: Text("sk-...").foregroundStyle(Theme.textSecondary.opacity(0.5)))
                            .font(.caption)
                            .foregroundStyle(Theme.textPrimary)
                        }

                        Button {
                            showApiKey.toggle()
                        } label: {
                            Image(systemName: showApiKey ? "eye.slash" : "eye")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(10)
                    .background(Theme.background)
                    .clipShape(.rect(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.surfaceBorder, lineWidth: 1))
                }

                if !storage.apiUsage.isEmpty {
                    Rectangle()
                        .fill(Theme.surfaceBorder)
                        .frame(height: 1)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Usage Log")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)

                        ForEach(storage.apiUsage) { entry in
                            HStack {
                                Text(entry.caseTitle)
                                    .font(.caption2)
                                    .foregroundStyle(Theme.textPrimary)
                                    .lineLimit(1)
                                Spacer()
                                Text("\(entry.tokensUsed) tokens")
                                    .font(.caption2)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private var dataPrivacySection: some View {
        SettingsSection(title: "Data & Privacy", icon: "lock.shield") {
            VStack(spacing: 10) {
                Button {
                    showClearConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .font(.subheadline)
                        Text("Clear All Cases")
                            .font(.subheadline)
                        Spacer()
                        Text("\(storage.cases.count) cases")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .foregroundStyle(Theme.danger)
                    .padding(12)
                    .background(Theme.danger.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 10))
                }

                ShareLink(item: storage.exportAllCasesText()) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.subheadline)
                        Text("Export All Cases")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .foregroundStyle(Theme.accent)
                    .padding(12)
                    .background(Theme.accent.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
    }

    private var aboutSection: some View {
        SettingsSection(title: "About", icon: "info.circle") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Version")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("1.0.0")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }

                Rectangle()
                    .fill(Theme.surfaceBorder)
                    .frame(height: 1)

                Text("PolicyCheck UK is not a substitute for professional legal advice. All analysis is indicative only and should be verified by a qualified insurance professional before any decisions are made.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(4)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Theme.accent)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            VStack(spacing: 0) {
                content
            }
            .padding(14)
            .background(Theme.surface)
            .clipShape(.rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.surfaceBorder, lineWidth: 1))
        }
    }
}

struct SettingsTextField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.textSecondary)

            TextField("", text: $text, prompt: Text(label).foregroundStyle(Theme.textSecondary.opacity(0.5)))
                .font(.subheadline)
                .padding(10)
                .background(Theme.background)
                .foregroundStyle(Theme.textPrimary)
                .clipShape(.rect(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.surfaceBorder, lineWidth: 1))
        }
    }
}
