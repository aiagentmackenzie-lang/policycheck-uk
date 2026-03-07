import SwiftUI

struct HistoryView: View {
    let storage: StorageService
    @State private var searchText: String = ""

    private var filteredCases: [PolicyCase] {
        if searchText.isEmpty {
            return storage.cases
        }
        return storage.cases.filter {
            $0.title.localizedStandardContains(searchText) ||
            $0.referenceNumber.localizedStandardContains(searchText)
        }
    }

    private var groupedCases: [(String, [PolicyCase])] {
        let grouped = Dictionary(grouping: filteredCases) { storage.dateGroup($0.createdAt) }
        let order = ["Today", "Yesterday", "This Week", "Older"]
        return order.compactMap { group in
            guard let cases = grouped[group], !cases.isEmpty else { return nil }
            return (group, cases)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if storage.cases.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(groupedCases, id: \.0) { group, cases in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(group)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Theme.textSecondary)
                                        .padding(.horizontal, 4)

                                    ForEach(cases) { pCase in
                                        NavigationLink(value: pCase.id) {
                                            HistoryRow(policyCase: pCase, storage: storage)
                                        }
                                    }
                                }
                            }

                            if filteredCases.isEmpty && !searchText.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.title)
                                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                                    Text("No results for \"\(searchText)\"")
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                    .navigationDestination(for: String.self) { caseID in
                        CaseDetailView(caseID: caseID, storage: storage)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search by title or reference")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(Theme.textSecondary.opacity(0.4))

            Text("No case history yet")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Text("Cases you create and analyse will appear here.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }
}

struct HistoryRow: View {
    let policyCase: PolicyCase
    let storage: StorageService

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(policyCase.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    LOBBadge(lineOfBusiness: policyCase.lineOfBusiness)

                    if let analysis = policyCase.analysis {
                        VerdictChip(verdict: analysis.overallVerdict)
                    }
                }

                Text(storage.formatDate(policyCase.createdAt))
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                StatusPill(status: policyCase.status)

                if policyCase.humanReview != nil {
                    HStack(spacing: 2) {
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .font(.caption2)
                        Text("Reviewed")
                            .font(.caption2)
                    }
                    .foregroundStyle(Theme.success)
                }
            }
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.surfaceBorder, lineWidth: 1))
    }
}
