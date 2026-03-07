import Foundation

nonisolated enum CaseStatus: String, Codable, Sendable, CaseIterable {
    case pending
    case analysed
    case reviewed
    case closed
}

nonisolated enum OverallVerdict: String, Codable, Sendable {
    case covered = "COVERED"
    case notCovered = "NOT_COVERED"
    case ambiguous = "AMBIGUOUS"
    case escalate = "ESCALATE"
}

nonisolated enum LevelVerdict: String, Codable, Sendable {
    case pass = "PASS"
    case fail = "FAIL"
    case ambiguous = "AMBIGUOUS"
}

nonisolated enum ReviewDecision: String, Codable, Sendable {
    case agree = "AGREE"
    case disagree = "DISAGREE"
    case overrideDecision = "OVERRIDE"
}

nonisolated enum LineOfBusiness: String, Codable, Sendable, CaseIterable, Identifiable {
    case property = "Property"
    case motor = "Motor"
    case liability = "Liability"
    case life = "Life"
    case all = "All"

    var id: String { rawValue }
}

nonisolated struct LevelResult: Codable, Sendable, Identifiable {
    var id: String { label }
    let label: String
    let verdict: LevelVerdict
    let reasoning: String
    let flaggedClauses: [String]
}

nonisolated struct Analysis: Codable, Sendable {
    let level1Eligibility: LevelResult
    let level2Coverage: LevelResult
    let level3Compliance: LevelResult
    let overallVerdict: OverallVerdict
    let confidence: Int
    let relevantSections: [String]
    let generatedAt: String
    let isSimulated: Bool
}

nonisolated struct HumanReview: Codable, Sendable {
    let decision: ReviewDecision
    let rationale: String
    let reviewerName: String
    let reviewedAt: String
}

nonisolated struct PolicyCase: Codable, Sendable, Identifiable {
    let id: String
    var title: String
    var lineOfBusiness: String
    var referenceNumber: String
    var policyText: String
    var claimText: String
    let createdAt: String
    var status: CaseStatus
    var analysis: Analysis?
    var humanReview: HumanReview?

    init(
        id: String = UUID().uuidString,
        title: String,
        lineOfBusiness: String,
        referenceNumber: String = "",
        policyText: String,
        claimText: String,
        createdAt: String = ISO8601DateFormatter().string(from: Date()),
        status: CaseStatus = .pending,
        analysis: Analysis? = nil,
        humanReview: HumanReview? = nil
    ) {
        self.id = id
        self.title = title
        self.lineOfBusiness = lineOfBusiness
        self.referenceNumber = referenceNumber
        self.policyText = policyText
        self.claimText = claimText
        self.createdAt = createdAt
        self.status = status
        self.analysis = analysis
        self.humanReview = humanReview
    }
}

nonisolated struct AppSettings: Codable, Sendable {
    var reviewerName: String
    var organisation: String
    var lineOfBusinessFocus: String
    var openaiApiKey: String
    var useSimulatedData: Bool
    var legislationApiEnabled: Bool

    init(
        reviewerName: String = "",
        organisation: String = "",
        lineOfBusinessFocus: String = "All",
        openaiApiKey: String = "",
        useSimulatedData: Bool = true,
        legislationApiEnabled: Bool = false
    ) {
        self.reviewerName = reviewerName
        self.organisation = organisation
        self.lineOfBusinessFocus = lineOfBusinessFocus
        self.openaiApiKey = openaiApiKey
        self.useSimulatedData = useSimulatedData
        self.legislationApiEnabled = legislationApiEnabled
    }
}

nonisolated struct APIUsageEntry: Codable, Sendable, Identifiable {
    let id: String
    let timestamp: String
    let tokensUsed: Int
    let caseTitle: String

    init(id: String = UUID().uuidString, timestamp: String = ISO8601DateFormatter().string(from: Date()), tokensUsed: Int, caseTitle: String) {
        self.id = id
        self.timestamp = timestamp
        self.tokensUsed = tokensUsed
        self.caseTitle = caseTitle
    }
}
