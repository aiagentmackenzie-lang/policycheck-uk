import SwiftUI

struct CaseDetailView: View {
    let caseID: String
    let storage: StorageService
    @State private var showReviewSheet: Bool = false
    @State private var showFullPolicy: Bool = false
    @State private var showFullClaim: Bool = false
    @State private var isRunningAnalysis: Bool = false
    @State private var analysisStep: String = ""
    @State private var hapticTrigger: Bool = false
    @Environment(\.dismiss) private var dismiss

    private var policyCase: PolicyCase? {
        storage.cases.first { $0.id == caseID }
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if let pCase = policyCase {
                if isRunningAnalysis {
                    analysisLoadingView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            headerSection(pCase)

                            documentSection(title: "Policy Document", icon: "doc.text", text: pCase.policyText, isExpanded: $showFullPolicy)

                            documentSection(title: "Claim Document", icon: "doc.plaintext", text: pCase.claimText, isExpanded: $showFullClaim)

                            if let analysis = pCase.analysis {
                                analysisSection(analysis)
                            } else {
                                runAnalysisPrompt(pCase)
                            }

                            if pCase.analysis != nil {
                                HumanReviewCard(review: pCase.humanReview) {
                                    showReviewSheet = true
                                }
                            }

                            Text("For guidance only. Not legal advice.")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary.opacity(0.4))
                                .padding(.top, 8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationTitle(policyCase?.title ?? "Case Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if let pCase = policyCase, pCase.analysis != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: generateShareText(pCase)) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $showReviewSheet) {
            if let pCase = policyCase {
                HumanReviewSheet(
                    policyCase: pCase,
                    storage: storage,
                    defaultReviewerName: storage.settings.reviewerName
                )
            }
        }
        .sensoryFeedback(.success, trigger: hapticTrigger)
    }

    private func headerSection(_ pCase: PolicyCase) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                LOBBadge(lineOfBusiness: pCase.lineOfBusiness)
                StatusPill(status: pCase.status)
                Spacer()
                Text(storage.formatDate(pCase.createdAt))
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            if !pCase.referenceNumber.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "number")
                        .font(.caption2)
                    Text(pCase.referenceNumber)
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.surfaceBorder, lineWidth: 1))
    }

    private func documentSection(title: String, icon: String, text: String, isExpanded: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(Theme.accent)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .rotationEffect(.degrees(isExpanded.wrappedValue ? 90 : 0))
                }
                .padding(14)
            }

            if isExpanded.wrappedValue {
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle()
                        .fill(Theme.surfaceBorder)
                        .frame(height: 1)

                    Text(text)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(4)
                        .padding(14)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.surfaceBorder, lineWidth: 1))
    }

    private func analysisSection(_ analysis: Analysis) -> some View {
        VStack(spacing: 12) {
            VerdictBanner(analysis: analysis)

            LevelCard(levelNumber: 1, result: analysis.level1Eligibility)
            LevelCard(levelNumber: 2, result: analysis.level2Coverage)
            LevelCard(levelNumber: 3, result: analysis.level3Compliance)

            relevantSectionsCard(analysis.relevantSections)
        }
    }

    private func relevantSectionsCard(_ sections: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "books.vertical")
                    .foregroundStyle(Theme.accent)
                Text("Relevant Legislation & Rules")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            FlowLayout(spacing: 6) {
                ForEach(sections, id: \.self) { section in
                    Text(section)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Theme.accent.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 6))
                }
            }
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.surfaceBorder, lineWidth: 1))
    }

    private func runAnalysisPrompt(_ pCase: PolicyCase) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "bolt.shield")
                .font(.system(size: 36))
                .foregroundStyle(Theme.accent)

            Text("Ready to Analyse")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Text("Run the 4-level compliance analysis on this case.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                runAnalysis(pCase)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.shield.fill")
                    Text("Run Analysis")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.accent)
                .clipShape(.rect(cornerRadius: 14))
            }
        }
        .padding(20)
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.surfaceBorder, lineWidth: 1))
    }

    private var analysisLoadingView: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "shield.checkered")
                .font(.system(size: 48))
                .foregroundStyle(Theme.accent)
                .symbolEffect(.pulse, options: .repeating)

            Text(analysisStep)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.textPrimary)
                .animation(.easeInOut(duration: 0.3), value: analysisStep)

            ProgressView()
                .tint(Theme.accent)

            Spacer()
        }
    }

    private func runAnalysis(_ pCase: PolicyCase) {
        isRunningAnalysis = true
        analysisStep = "Level 1: Checking eligibility..."

        Task {
            do {
                let analysis = try await AnalysisService.analyseCase(
                    policyText: pCase.policyText,
                    claimText: pCase.claimText,
                    lineOfBusiness: pCase.lineOfBusiness,
                    useSimulated: storage.settings.useSimulatedData
                )

                var updated = pCase
                updated.analysis = analysis
                updated.status = .analysed
                storage.updateCase(updated)

                isRunningAnalysis = false
                hapticTrigger.toggle()
            } catch {
                isRunningAnalysis = false
            }
        }
    }

    private func generateShareText(_ pCase: PolicyCase) -> String {
        var text = "PolicyCheck UK — Case Summary\n"
        text += String(repeating: "━", count: 35) + "\n"
        text += "Case: \(pCase.title)\n"
        text += "Line of Business: \(pCase.lineOfBusiness)\n"
        text += "Status: \(pCase.status.rawValue.capitalized)\n\n"

        if let analysis = pCase.analysis {
            text += "Overall Verdict: \(analysis.overallVerdict.rawValue)\n"
            text += "Confidence: \(analysis.confidence)%\n"
            text += "Level 1 (Eligibility): \(analysis.level1Eligibility.verdict.rawValue)\n"
            text += "Level 2 (Coverage): \(analysis.level2Coverage.verdict.rawValue)\n"
            text += "Level 3 (Compliance): \(analysis.level3Compliance.verdict.rawValue)\n\n"
        }

        if let review = pCase.humanReview {
            text += "Human Review: \(review.decision.rawValue)\n"
            text += "Rationale: \(review.rationale)\n"
            text += "Reviewer: \(review.reviewerName)\n\n"
        }

        text += "Disclaimer: For guidance only. Not legal advice.\n"
        return text
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
