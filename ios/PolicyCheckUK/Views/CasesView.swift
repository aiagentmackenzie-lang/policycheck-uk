import SwiftUI

struct CasesView: View {
    let storage: StorageService
    @State private var selectedFilter: CaseFilter = .all
    @State private var selectedCaseID: String?

    private enum CaseFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case analysed = "Analysed"
        case reviewed = "Reviewed"
    }

    private var filteredCases: [PolicyCase] {
        let active = storage.activeCases
        switch selectedFilter {
        case .all: return active
        case .pending: return active.filter { $0.status == .pending }
        case .analysed: return active.filter { $0.status == .analysed }
        case .reviewed: return active.filter { $0.status == .reviewed }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    filterBar

                    if filteredCases.isEmpty {
                        emptyCasesView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(filteredCases) { pCase in
                                    NavigationLink(value: pCase.id) {
                                        CaseCard(policyCase: pCase, storage: storage)
                                    }
                                    .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: pCase.id)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 100)
                        }
                    }
                }
                .navigationDestination(for: String.self) { caseID in
                    if let pCase = storage.cases.first(where: { $0.id == caseID }) {
                        CaseDetailView(caseID: caseID, storage: storage)
                    }
                }
            }
            .navigationTitle("Active Cases")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Text("\(filteredCases.count)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.accent)
                            .clipShape(.rect(cornerRadius: 6))
                    }
                }
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CaseFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(selectedFilter == filter ? .white : Theme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedFilter == filter ? Theme.accent : Theme.surface)
                            .clipShape(.rect(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedFilter == filter ? .clear : Theme.surfaceBorder, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Theme.background)
    }

    private var emptyCasesView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(Theme.textSecondary.opacity(0.4))

            Text("No active cases")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Text("Tap the New Case tab to create your first case.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
