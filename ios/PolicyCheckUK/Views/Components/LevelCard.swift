import SwiftUI

struct LevelCard: View {
    let levelNumber: Int
    let result: LevelResult
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(duration: 0.35)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Theme.levelVerdictColor(for: result.verdict).opacity(0.15))
                            .frame(width: 36, height: 36)

                        Text("\(levelNumber)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Theme.levelVerdictColor(for: result.verdict))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.label)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)

                        LevelVerdictPill(verdict: result.verdict)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(14)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Rectangle()
                        .fill(Theme.surfaceBorder)
                        .frame(height: 1)

                    Text(result.reasoning)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(4)

                    if !result.flaggedClauses.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Flagged Clauses")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)

                            ForEach(result.flaggedClauses, id: \.self) { clause in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.caption2)
                                        .foregroundStyle(Theme.warning)

                                    Text(clause)
                                        .font(.caption)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.surfaceBorder, lineWidth: 1)
        )
    }
}

struct LevelVerdictPill: View {
    let verdict: LevelVerdict

    var body: some View {
        Text(verdict.rawValue)
            .font(.caption2.weight(.bold))
            .foregroundStyle(Theme.levelVerdictColor(for: verdict))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Theme.levelVerdictColor(for: verdict).opacity(0.12))
            .clipShape(.rect(cornerRadius: 4))
    }
}

struct HumanReviewCard: View {
    let review: HumanReview?
    let onAddReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(review != nil ? Theme.success.opacity(0.15) : Theme.surfaceBorder.opacity(0.5))
                        .frame(width: 36, height: 36)

                    Text("4")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(review != nil ? Theme.success : Theme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Human Review")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)

                    if let review {
                        Text(review.decision.rawValue)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(decisionColor(review.decision))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(decisionColor(review.decision).opacity(0.12))
                            .clipShape(.rect(cornerRadius: 4))
                    } else {
                        Text("Awaiting review")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Spacer()

                Button {
                    onAddReview()
                } label: {
                    Text(review != nil ? "Edit" : "Add Review")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.accent.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .padding(14)

            if let review {
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(Theme.surfaceBorder)
                        .frame(height: 1)

                    Text(review.rationale)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(4)

                    HStack {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                        Text(review.reviewerName)
                            .font(.caption2.weight(.medium))
                        Spacer()
                        Text(formatReviewDate(review.reviewedAt))
                            .font(.caption2)
                    }
                    .foregroundStyle(Theme.textSecondary.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.surfaceBorder, lineWidth: 1)
        )
    }

    private func decisionColor(_ decision: ReviewDecision) -> Color {
        switch decision {
        case .agree: return Theme.success
        case .disagree: return Theme.danger
        case .overrideDecision: return Theme.warning
        }
    }

    private func formatReviewDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return iso }
        let display = DateFormatter()
        display.dateStyle = .short
        display.timeStyle = .short
        display.locale = Locale(identifier: "en_GB")
        return display.string(from: date)
    }
}
