import Foundation

@Observable
@MainActor
class StorageService {
    var cases: [PolicyCase] = []
    var settings: AppSettings = AppSettings()
    var apiUsage: [APIUsageEntry] = []
    var hasCompletedOnboarding: Bool = false

    private let casesKey = "policycheck_cases"
    private let settingsKey = "policycheck_settings"
    private let apiUsageKey = "policycheck_api_usage"
    private let onboardingKey = "policycheck_onboarding_complete"

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init() {
        loadAll()
    }

    func loadAll() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        if let data = UserDefaults.standard.data(forKey: casesKey),
           let decoded = try? decoder.decode([PolicyCase].self, from: data) {
            cases = decoded
        }
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? decoder.decode(AppSettings.self, from: data) {
            settings = decoded
        }
        if let data = UserDefaults.standard.data(forKey: apiUsageKey),
           let decoded = try? decoder.decode([APIUsageEntry].self, from: data) {
            apiUsage = decoded
        }
    }

    func saveCases() {
        if let data = try? encoder.encode(cases) {
            UserDefaults.standard.set(data, forKey: casesKey)
        }
    }

    func saveSettings() {
        if let data = try? encoder.encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }

    func saveApiUsage() {
        if let data = try? encoder.encode(apiUsage) {
            UserDefaults.standard.set(data, forKey: apiUsageKey)
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    func addCase(_ newCase: PolicyCase) {
        cases.insert(newCase, at: 0)
        saveCases()
    }

    func updateCase(_ updatedCase: PolicyCase) {
        if let index = cases.firstIndex(where: { $0.id == updatedCase.id }) {
            cases[index] = updatedCase
            saveCases()
        }
    }

    func deleteCase(id: String) {
        cases.removeAll { $0.id == id }
        saveCases()
    }

    func clearAllCases() {
        cases.removeAll()
        saveCases()
    }

    func addApiUsage(tokensUsed: Int, caseTitle: String) {
        let entry = APIUsageEntry(tokensUsed: tokensUsed, caseTitle: caseTitle)
        apiUsage.insert(entry, at: 0)
        if apiUsage.count > 10 {
            apiUsage = Array(apiUsage.prefix(10))
        }
        saveApiUsage()
    }

    var activeCases: [PolicyCase] {
        cases.filter { $0.status != .closed }
    }

    func exportAllCasesText() -> String {
        var output = "PolicyCheck UK — Case Export\n"
        output += "Generated: \(Date().formatted())\n"
        output += String(repeating: "━", count: 40) + "\n\n"

        for pCase in cases {
            output += "Case: \(pCase.title)\n"
            output += "Line of Business: \(pCase.lineOfBusiness)\n"
            output += "Status: \(pCase.status.rawValue.capitalized)\n"
            output += "Created: \(formatDate(pCase.createdAt))\n"

            if let analysis = pCase.analysis {
                output += "\nAnalysis (\(analysis.isSimulated ? "Simulated" : "Live AI")):\n"
                output += "  Overall Verdict: \(analysis.overallVerdict.rawValue)\n"
                output += "  Confidence: \(analysis.confidence)%\n"
                output += "  Level 1 (Eligibility): \(analysis.level1Eligibility.verdict.rawValue)\n"
                output += "  Level 2 (Coverage): \(analysis.level2Coverage.verdict.rawValue)\n"
                output += "  Level 3 (Compliance): \(analysis.level3Compliance.verdict.rawValue)\n"
                output += "  Relevant Sections: \(analysis.relevantSections.joined(separator: ", "))\n"
            }

            if let review = pCase.humanReview {
                output += "\nHuman Review:\n"
                output += "  Decision: \(review.decision.rawValue)\n"
                output += "  Rationale: \(review.rationale)\n"
                output += "  Reviewer: \(review.reviewerName)\n"
            }

            output += "\n" + String(repeating: "─", count: 40) + "\n\n"
        }

        output += "Disclaimer: For guidance only. Not legal advice.\n"
        return output
    }

    func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return isoString }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "en_GB")
        return displayFormatter.string(from: date)
    }

    func relativeDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return isoString }
        let relative = RelativeDateTimeFormatter()
        relative.locale = Locale(identifier: "en_GB")
        return relative.localizedString(for: date, relativeTo: Date())
    }

    func dateGroup(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return "Older" }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        if date > weekAgo { return "This Week" }
        return "Older"
    }
}
