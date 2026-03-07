import SwiftUI

struct CaseCard: View {
    let policyCase: PolicyCase
    let storage: StorageService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(policyCase.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(2)

                    Text(storage.relativeDate(policyCase.createdAt))
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                StatusPill(status: policyCase.status)
            }

            HStack(spacing: 8) {
                LOBBadge(lineOfBusiness: policyCase.lineOfBusiness)

                if let analysis = policyCase.analysis {
                    VerdictChip(verdict: analysis.overallVerdict)
                }

                Spacer()

                if policyCase.humanReview != nil {
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.success)
                }
            }
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.surfaceBorder, lineWidth: 1)
        )
    }
}

struct StatusPill: View {
    let status: CaseStatus

    var body: some View {
        Text(statusLabel)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Theme.statusColor(for: status))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Theme.statusColor(for: status).opacity(0.12))
            .clipShape(.rect(cornerRadius: 6))
    }

    private var statusLabel: String {
        switch status {
        case .pending: return "Pending"
        case .analysed: return "Analysed"
        case .reviewed: return "Reviewed"
        case .closed: return "Closed"
        }
    }
}

struct LOBBadge: View {
    let lineOfBusiness: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: lobIcon)
                .font(.caption2)
            Text(lineOfBusiness)
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(Theme.textSecondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Theme.surfaceBorder.opacity(0.5))
        .clipShape(.rect(cornerRadius: 6))
    }

    private var lobIcon: String {
        switch lineOfBusiness {
        case "Property": return "building.2"
        case "Motor": return "car"
        case "Liability": return "person.2"
        case "Life": return "heart"
        default: return "doc"
        }
    }
}

struct VerdictChip: View {
    let verdict: OverallVerdict

    var body: some View {
        Text(verdict.rawValue.replacingOccurrences(of: "_", with: " "))
            .font(.caption2.weight(.bold))
            .foregroundStyle(verdictStyle)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(verdictBackground)
            .clipShape(.rect(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(verdict == .escalate ? Theme.danger : .clear, lineWidth: 1)
            )
    }

    private var verdictStyle: Color {
        switch verdict {
        case .covered: return Theme.success
        case .notCovered: return Theme.danger
        case .ambiguous: return Theme.warning
        case .escalate: return Theme.danger
        }
    }

    private var verdictBackground: Color {
        switch verdict {
        case .covered: return Theme.success.opacity(0.12)
        case .notCovered: return Theme.danger.opacity(0.12)
        case .ambiguous: return Theme.warning.opacity(0.12)
        case .escalate: return .clear
        }
    }
}
