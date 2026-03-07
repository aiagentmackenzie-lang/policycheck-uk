import SwiftUI

struct NewCaseView: View {
    let storage: StorageService
    @State private var currentStep: Int = 1
    @State private var caseTitle: String = ""
    @State private var lineOfBusiness: String = "Property"
    @State private var referenceNumber: String = ""
    @State private var policyText: String = ""
    @State private var claimText: String = ""
    @State private var showPolicyPaste: Bool = false
    @State private var showClaimPaste: Bool = false
    @State private var isAnalysing: Bool = false
    @State private var analysisStep: String = ""
    @State private var analysisError: String?
    @State private var createdCaseID: String?
    @State private var navigateToDetail: Bool = false
    @State private var hapticTrigger: Bool = false

    private let lobOptions = ["Property", "Motor", "Liability", "Life"]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    StepIndicator(current: currentStep, total: 3)
                        .padding(.top, 16)

                    Text(stepTitle)
                        .font(.system(.title3, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.top, 8)

                    switch currentStep {
                    case 1: step1View
                    case 2: step2View
                    case 3: step3View
                    default: EmptyView()
                    }
                }
                .navigationDestination(isPresented: $navigateToDetail) {
                    if let caseID = createdCaseID {
                        CaseDetailView(caseID: caseID, storage: storage)
                    }
                }
            }
            .navigationTitle("New Case")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sensoryFeedback(.success, trigger: hapticTrigger)
        }
    }

    private var stepTitle: String {
        switch currentStep {
        case 1: return "Case Details"
        case 2: return "Upload Documents"
        case 3: return "Run Analysis"
        default: return ""
        }
    }

    private var step1View: some View {
        ScrollView {
            VStack(spacing: 20) {
                InputField(label: "Case Title", placeholder: "e.g. Flood Damage – Policy REF-4821", text: $caseTitle)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Line of Business")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textSecondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(lobOptions, id: \.self) { option in
                            Button {
                                lineOfBusiness = option
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: lobIcon(option))
                                        .font(.caption)
                                    Text(option)
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundStyle(lineOfBusiness == option ? .white : Theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(lineOfBusiness == option ? Theme.accent : Theme.surface)
                                .clipShape(.rect(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineOfBusiness == option ? .clear : Theme.surfaceBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                }

                InputField(label: "Reference Number (optional)", placeholder: "e.g. REF-4821", text: $referenceNumber)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 100)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            bottomButton(title: "Next", enabled: !caseTitle.trimmingCharacters(in: .whitespaces).isEmpty) {
                withAnimation(.spring(duration: 0.35)) { currentStep = 2 }
            }
        }
    }

    private var step2View: some View {
        ScrollView {
            VStack(spacing: 20) {
                documentSection(
                    title: "Policy Document",
                    icon: "doc.text",
                    text: $policyText,
                    showPaste: $showPolicyPaste,
                    onScan: { policyText = AnalysisService.extractTextFromImage(lineOfBusiness: lineOfBusiness) }
                )

                documentSection(
                    title: "Claim Document",
                    icon: "doc.plaintext",
                    text: $claimText,
                    showPaste: $showClaimPaste,
                    onScan: { claimText = AnalysisService.extractClaimText(lineOfBusiness: lineOfBusiness) }
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 100)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(duration: 0.35)) { currentStep = 1 }
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.surface)
                        .clipShape(.rect(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.surfaceBorder, lineWidth: 1))
                }

                Button {
                    withAnimation(.spring(duration: 0.35)) { currentStep = 3 }
                } label: {
                    Text("Next")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(documentsReady ? Theme.accent : Theme.accent.opacity(0.3))
                        .clipShape(.rect(cornerRadius: 14))
                }
                .disabled(!documentsReady)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .background(Theme.background)
        }
    }

    private var step3View: some View {
        VStack(spacing: 0) {
            if isAnalysing {
                analysisLoadingView
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        summaryCard

                        if let error = analysisError {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Theme.danger)
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textSecondary)
                                    .multilineTextAlignment(.center)
                                Button {
                                    runAnalysis()
                                } label: {
                                    Text("Retry")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Theme.accent)
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(Theme.danger.opacity(0.08))
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.danger.opacity(0.2), lineWidth: 1))
                        }

                        Text("For guidance only. Not legal advice.")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary.opacity(0.5))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
                .safeAreaInset(edge: .bottom) {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(duration: 0.35)) { currentStep = 2 }
                        } label: {
                            Text("Back")
                                .font(.headline)
                                .foregroundStyle(Theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Theme.surface)
                                .clipShape(.rect(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.surfaceBorder, lineWidth: 1))
                        }

                        Button {
                            runAnalysis()
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
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .background(Theme.background)
                }
            }
        }
    }

    private var analysisLoadingView: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Theme.surfaceBorder, lineWidth: 3)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Theme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnalysing)

                Image(systemName: "shield.checkered")
                    .font(.title)
                    .foregroundStyle(Theme.accent)
                    .symbolEffect(.pulse, options: .repeating)
            }

            Text(analysisStep)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.textPrimary)
                .animation(.easeInOut(duration: 0.3), value: analysisStep)

            Spacer()
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(Theme.accent)
                Text("Case Summary")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 6) {
                summaryRow(label: "Title", value: caseTitle)
                summaryRow(label: "Line of Business", value: lineOfBusiness)
                if !referenceNumber.isEmpty {
                    summaryRow(label: "Reference", value: referenceNumber)
                }
                summaryRow(label: "Policy Document", value: "\(policyText.prefix(80))...")
                summaryRow(label: "Claim Document", value: "\(claimText.prefix(80))...")
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.surfaceBorder, lineWidth: 1))
    }

    private func summaryRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(.caption)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
        }
    }

    private func documentSection(
        title: String,
        icon: String,
        text: Binding<String>,
        showPaste: Binding<Bool>,
        onScan: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Theme.accent)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                if !text.wrappedValue.isEmpty {
                    Button {
                        text.wrappedValue = ""
                        showPaste.wrappedValue = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }

            if text.wrappedValue.isEmpty {
                VStack(spacing: 12) {
                    Button {
                        onScan()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                            Text("Scan Document")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.accent.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 10))
                    }

                    Button {
                        showPaste.wrappedValue.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.on.clipboard")
                            Text("Paste Text")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.surface)
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.surfaceBorder, lineWidth: 1))
                    }

                    if showPaste.wrappedValue {
                        TextEditor(text: text)
                            .font(.caption)
                            .foregroundStyle(Theme.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 120)
                            .padding(10)
                            .background(Theme.surface)
                            .clipShape(.rect(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.surfaceBorder, lineWidth: 1))
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(text.wrappedValue.prefix(200)) + "...")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(5)

                    Text("\(text.wrappedValue.count) characters")
                        .font(.caption2)
                        .foregroundStyle(Theme.accent)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface)
                .clipShape(.rect(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.surfaceBorder, lineWidth: 1))
            }
        }
        .padding(16)
        .background(Theme.surface.opacity(0.3))
        .clipShape(.rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.surfaceBorder, lineWidth: 1))
    }

    private var documentsReady: Bool {
        !policyText.trimmingCharacters(in: .whitespaces).isEmpty &&
        !claimText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func bottomButton(title: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(enabled ? Theme.accent : Theme.accent.opacity(0.3))
                .clipShape(.rect(cornerRadius: 14))
        }
        .disabled(!enabled)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(Theme.background)
    }

    private func lobIcon(_ lob: String) -> String {
        switch lob {
        case "Property": return "building.2"
        case "Motor": return "car"
        case "Liability": return "person.2"
        case "Life": return "heart"
        default: return "doc"
        }
    }

    private func runAnalysis() {
        isAnalysing = true
        analysisError = nil

        Task {
            do {
                analysisStep = "Level 1: Checking eligibility..."
                let analysis = try await AnalysisService.analyseCase(
                    policyText: policyText,
                    claimText: claimText,
                    lineOfBusiness: lineOfBusiness,
                    useSimulated: storage.settings.useSimulatedData
                )

                var newCase = PolicyCase(
                    title: caseTitle,
                    lineOfBusiness: lineOfBusiness,
                    referenceNumber: referenceNumber,
                    policyText: policyText,
                    claimText: claimText,
                    status: .analysed,
                    analysis: analysis
                )

                storage.addCase(newCase)
                createdCaseID = newCase.id

                isAnalysing = false
                hapticTrigger.toggle()

                resetForm()
                navigateToDetail = true
            } catch {
                isAnalysing = false
                analysisError = "Analysis failed. Please try again."
            }
        }
    }

    private func resetForm() {
        currentStep = 1
        caseTitle = ""
        lineOfBusiness = "Property"
        referenceNumber = ""
        policyText = ""
        claimText = ""
        showPolicyPaste = false
        showClaimPaste = false
    }
}

struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.textSecondary)

            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Theme.textSecondary.opacity(0.5)))
                .padding(14)
                .background(Theme.surface)
                .foregroundStyle(Theme.textPrimary)
                .clipShape(.rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme.surfaceBorder, lineWidth: 1)
                )
        }
    }
}
