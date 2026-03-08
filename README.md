# 🛡️ PolicyCheck UK — Compliance Co-Pilot for Insurance Professionals

**AI-powered insurance policy analysis for UK brokers and underwriters**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17+-blue)](https://developer.apple.com/ios)
[![License: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 📋 Project Overview

**PolicyCheck UK** is a native iOS application that helps UK insurance professionals analyze policies and claims against regulatory requirements. It provides AI-driven compliance checking with human review workflows.

### Target Users
- 🏢 **Insurance Brokers** — Validate policy coverage before presenting to clients
- 📋 **Underwriters** — Assess claim eligibility against policy terms
- ⚖️ **Compliance Officers** — Ensure regulatory alignment across cases

---

## ✨ Key Features

### 📊 Case Management
- **Active Cases Dashboard** — View all active cases with status filters (All / Pending / Analysed / Awaiting Review)
- **Case History** — All cases grouped by date with search, verdict chips, and review status
- **New Case Wizard** — 3-step guided flow: enter details → upload documents → run analysis

### 🔍 AI-Powered Analysis
- **4-Level Analysis Engine** — Eligibility check, coverage analysis, regulatory compliance, and human review
- **UK Regulation Citations** — References Insurance Act 2015, FCA ICOBS, and other UK legislation
- **Simulated AI Mode** — Realistic mock responses based on document keywords (flood exclusions, theft coverage, etc.)

### 👤 Human Review Workflow
- **Review Decisions** — Agree, disagree, or override AI analysis
- **Rationale Tracking** — Document reviewer reasoning with each decision
- **Approval Workflow** — Structured sign-off process for compliance

### ⚙️ Settings & Configuration
- **Profile Management** — Name, organisation, line of business
- **Analysis Engine Toggle** — Switch between simulated and live AI modes
- **Data Export** — Share plain text case summaries via iOS share sheet

---

## 🛠️ Technology Stack

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | Modern declarative UI framework |
| **iOS 17+** | Latest iOS features and capabilities |
| **Xcode** | Development environment |

### Native Capabilities
- **SF Symbols** — Consistent iOS iconography throughout
- **Haptic Feedback** — Tactile responses for interactions and verdicts
- **Share Sheet** — Export case summaries to other apps
- **UserDefaults** — Local data persistence

---

## 🚀 Getting Started

### Prerequisites
- macOS with Xcode 15+
- Apple Developer account (for device deployment)
- iOS 17+ device or simulator

### Installation

```bash
# Clone the repository
git clone https://github.com/aiagentmackenzie-lang/policycheck-uk.git
cd policycheck-uk

# Open in Xcode
open ios/PolicyCheckUK.xcworkspace
```

### Running the App

1. Open `ios/PolicyCheckUK.xcworkspace` in Xcode
2. Select a simulator or connected device
3. Press **Cmd + R** to build and run

### Building for Device

1. Select your development team in Signing & Capabilities
2. Choose your device as the run destination
3. Press **Cmd + R** to deploy

---

## 📁 Project Structure

```
policycheck-uk/
├── ios/
│   ├── PolicyCheckUK/           # Main app target
│   │   ├── Models/              # Data models
│   │   ├── Views/               # SwiftUI views
│   │   │   ├── Onboarding/      # Welcome, profile, analysis mode
│   │   │   └── Components/      # Reusable UI components
│   │   ├── Services/            # Business logic
│   │   ├── Utilities/           # Theme and helpers
│   │   └── Config.swift         # App configuration
│   ├── PolicyCheckUKTests/     # Unit tests
│   └── PolicyCheckUKUITests/   # UI tests
├── PLAN.md                     # Feature specification
└── .gitignore                  # Git ignore rules
```

---

## 🔐 Environment Setup

### API Configuration (Optional)

To enable live AI analysis, add your API key in Settings:

```swift
// In the app's Settings view, enter your API key
// The app stores it securely in iOS Keychain
```

For simulated mode (default), no API key required.

---

## 🧪 Testing

```bash
# Run unit tests
xcodebuild test -scheme PolicyCheckUK -destination 'platform=iOS Simulator'

# Run UI tests
xcodebuild test -scheme PolicyCheckUKUITests -destination 'platform=iOS Simulator'
```

---

## 👥 Credits

**Designed & Developed by:**
- **Raphael Main** — Product vision, domain expertise, iOS development
- **Agent Mackenzie** — AI implementation, compliance logic

**Contact:** [aiagent.mackenzie@gmail.com](mailto:aiagent.mackenzie@gmail.com)

---

## 📝 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- Apple SwiftUI team for the declarative UI framework
- UK Insurance industry standards and regulations

---

<p align="center">
  <strong>Scan. Analyse. Decide. Defend.</strong>
</p>

<p align="center">
  <em>Professional compliance checking for the modern insurance broker</em>
</p>
