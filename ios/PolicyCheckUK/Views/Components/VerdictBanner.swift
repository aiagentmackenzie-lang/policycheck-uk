import SwiftUI

struct VerdictBanner: View {
    let analysis: Analysis

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("OVERALL VERDICT")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)

                    Text(analysis.overallVerdict.rawValue.replacingOccurrences(of: "_", with: " "))
                        .font(.system(.title2, weight: .bold))
                        .foregroundStyle(Theme.verdictColor(for: analysis.overallVerdict))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("CONFIDENCE")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)

                    Text("\(analysis.confidence)%")
                        .font(.system(.title3, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surfaceBorder)
                        .frame(height: 6)

                    Capsule()
                        .fill(Theme.verdictColor(for: analysis.overallVerdict))
                        .frame(width: geo.size.width * CGFloat(analysis.confidence) / 100, height: 6)
                }
            }
            .frame(height: 6)

            HStack(spacing: 6) {
                Image(systemName: analysis.isSimulated ? "sparkles" : "brain")
                    .font(.caption2)
                Text(analysis.isSimulated ? "Simulated Analysis" : "Live AI Analysis")
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(analysis.isSimulated ? Theme.textSecondary : Theme.accent)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(analysis.isSimulated ? Theme.surfaceBorder.opacity(0.5) : Theme.accent.opacity(0.12))
            .clipShape(.rect(cornerRadius: 6))
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.verdictColor(for: analysis.overallVerdict).opacity(0.3), lineWidth: 1)
        )
    }
}
