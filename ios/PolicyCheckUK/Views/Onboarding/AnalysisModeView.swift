import SwiftUI

struct AnalysisModeView: View {
    @Binding var useSimulated: Bool
    @Binding var apiKey: String
    let onComplete: () -> Void

    @State private var showApiKeyField: Bool = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    StepIndicator(current: 3, total: 3)
                    Text("Analysis Mode")
                        .font(.system(.title2, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Choose how PolicyCheck analyses cases")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, 24)

                ScrollView {
                    VStack(spacing: 16) {
                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                useSimulated = true
                                showApiKeyField = false
                            }
                        } label: {
                            ModeCard(
                                icon: "sparkles",
                                title: "Simulated Analysis",
                                subtitle: "No API key needed",
                                description: "Realistic mock responses for testing and evaluation.",
                                isSelected: useSimulated
                            )
                        }

                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                useSimulated = false
                                showApiKeyField = true
                            }
                        } label: {
                            ModeCard(
                                icon: "brain",
                                title: "Live AI Analysis",
                                subtitle: "OpenAI API key required",
                                description: "Connect your key for real GPT-4o powered analysis.",
                                isSelected: !useSimulated
                            )
                        }

                        if showApiKeyField {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("OpenAI API Key")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Theme.textSecondary)

                                SecureField("", text: $apiKey, prompt: Text("sk-...").foregroundStyle(Theme.textSecondary.opacity(0.5)))
                                    .padding(14)
                                    .background(Theme.surface)
                                    .foregroundStyle(Theme.textPrimary)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Theme.surfaceBorder, lineWidth: 1)
                                    )

                                Text("Your key is stored locally and never shared.")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary.opacity(0.6))
                            }
                            .padding(.top, 4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                }
                .scrollDismissesKeyboard(.interactively)

                VStack(spacing: 0) {
                    Button {
                        onComplete()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.shield.fill")
                            Text("Enter PolicyCheck")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accent)
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
                .frame(width: 44, height: 44)
                .background(isSelected ? Theme.accent.opacity(0.15) : Theme.surface)
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Theme.accent)
                    }
                }
                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Theme.accent : Theme.surfaceBorder, lineWidth: isSelected ? 1.5 : 1)
        )
    }
}
