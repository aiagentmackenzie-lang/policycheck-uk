import SwiftUI

enum Theme {
    static let background = Color(red: 13/255, green: 15/255, blue: 20/255)
    static let surface = Color(red: 22/255, green: 27/255, blue: 34/255)
    static let surfaceBorder = Color(red: 31/255, green: 41/255, blue: 55/255)
    static let accent = Color(red: 47/255, green: 128/255, blue: 237/255)
    static let success = Color(red: 39/255, green: 174/255, blue: 96/255)
    static let warning = Color(red: 242/255, green: 153/255, blue: 74/255)
    static let danger = Color(red: 235/255, green: 87/255, blue: 87/255)
    static let textPrimary = Color(red: 234/255, green: 234/255, blue: 234/255)
    static let textSecondary = Color(red: 139/255, green: 148/255, blue: 158/255)

    static func verdictColor(for verdict: OverallVerdict) -> Color {
        switch verdict {
        case .covered: return success
        case .notCovered: return danger
        case .ambiguous: return warning
        case .escalate: return danger
        }
    }

    static func levelVerdictColor(for verdict: LevelVerdict) -> Color {
        switch verdict {
        case .pass: return success
        case .fail: return danger
        case .ambiguous: return warning
        }
    }

    static func statusColor(for status: CaseStatus) -> Color {
        switch status {
        case .pending: return textSecondary
        case .analysed: return accent
        case .reviewed: return success
        case .closed: return textSecondary.opacity(0.5)
        }
    }
}
