import SwiftUI

struct HumanReviewSheet: View {
    let policyCase: PolicyCase
    let storage: StorageService
    let defaultReviewerName: String

    @Environment(\.dismiss) private var dismiss
    @State private var selectedDecision: ReviewDecision?
    @State private var rationale: String = ""
    @State private var reviewerName: String = ""
    @State private var hapticTrigger: Bool = false

    private var isValid: Bool {
        selectedDecision != nil &&
        rationale.trimmingCharacters(in: .whitespaces).count >= 20 &&
        !reviewerName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let analysis = policyCase.analysis {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI VERDICT")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)

                            HStack {
                                VerdictChip(verdict: analysis.overallVerdict)
                                Text("Confidence: \(analysis.confidence)%")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.surface)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.surfaceBorder, lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("YOUR DECISION")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)

                        VStack(spacing: 8) {
                            decisionTile(
                                decision: .agree,
                                icon: "checkmark.circle.fill",
                                title: "Agree",
                                subtitle: "I concur with the AI analysis",
                                color: Theme.success
                            )

                            decisionTile(
                                decision: .disagree,
                                icon: "xmark.circle.fill",
                                title: "Disagree",
                                subtitle: "I disagree with the analysis",
                                color: Theme.danger
                            )

                            decisionTile(
                                decision: .overrideDecision,
                                icon: "arrow.triangle.2.circlepath",
                                title: "Override",
                                subtitle: "I am overriding with a different decision",
                                color: Theme.warning
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("RATIONALE")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)
                            Spacer()
                            Text("\(rationale.count) chars (min 20)")
                                .font(.caption2)
                                .foregroundStyle(rationale.count >= 20 ? Theme.success : Theme.textSecondary)
                        }

                        TextEditor(text: $rationale)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(Theme.surface)
                            .clipShape(.rect(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.surfaceBorder, lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("REVIEWER NAME")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)

                        TextField("", text: $reviewerName, prompt: Text("Your name").foregroundStyle(Theme.textSecondary.opacity(0.5)))
                            .font(.subheadline)
                            .padding(14)
                            .background(Theme.surface)
                            .foregroundStyle(Theme.textPrimary)
                            .clipShape(.rect(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.surfaceBorder, lineWidth: 1))
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background)
            .navigationTitle("Human Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        submitReview()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .sensoryFeedback(.success, trigger: hapticTrigger)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
        .onAppear {
            reviewerName = defaultReviewerName
            if let existing = policyCase.humanReview {
                selectedDecision = existing.decision
                rationale = existing.rationale
                reviewerName = existing.reviewerName
            }
        }
    }

    private func decisionTile(decision: ReviewDecision, icon: String, title: String, subtitle: String, color: Color) -> some View {
        Button {
            withAnimation(.spring(duration: 0.25)) {
                selectedDecision = decision
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(selectedDecision == decision ? color : Theme.textSecondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                if selectedDecision == decision {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(color)
                }
            }
            .padding(14)
            .background(Theme.surface)
            .clipShape(.rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedDecision == decision ? color : Theme.surfaceBorder, lineWidth: selectedDecision == decision ? 1.5 : 1)
            )
        }
    }

    private func submitReview() {
        guard let decision = selectedDecision else { return }

        let review = HumanReview(
            decision: decision,
            rationale: rationale,
            reviewerName: reviewerName,
            reviewedAt: ISO8601DateFormatter().string(from: Date())
        )

        var updated = policyCase
        updated.humanReview = review
        updated.status = .reviewed
        storage.updateCase(updated)

        hapticTrigger.toggle()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}
