import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Theme.accent.opacity(0.15))
                            .frame(width: 120, height: 120)

                        Circle()
                            .fill(Theme.accent.opacity(0.08))
                            .frame(width: 160, height: 160)

                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Theme.accent)
                            .symbolEffect(.pulse, options: .repeating)
                    }

                    VStack(spacing: 8) {
                        Text("PolicyCheck")
                            .font(.system(.largeTitle, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        +
                        Text(" UK")
                            .font(.system(.largeTitle, weight: .bold))
                            .foregroundStyle(Theme.accent)
                    }

                    Text("Scan. Analyse. Decide. Defend.")
                        .font(.system(.title3, weight: .semibold))
                        .foregroundStyle(Theme.accent.opacity(0.8))

                    Text("Helping UK insurance professionals make consistent, defensible decisions — powered by policy text and UK legislation.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                VStack(spacing: 16) {
                    Button {
                        onContinue()
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.accent)
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .sensoryFeedback(.impact(flexibility: .soft), trigger: false)

                    Text("v1.0 — For guidance only")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary.opacity(0.5))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
