import SwiftUI

struct ProfileSetupView: View {
    @Binding var name: String
    @Binding var organisation: String
    @Binding var lineOfBusiness: String
    let onContinue: () -> Void

    @FocusState private var focusedField: Field?

    private enum Field { case name, organisation }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !organisation.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private let lobOptions = ["Property", "Motor", "Liability", "Life", "All"]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    StepIndicator(current: 2, total: 3)
                    Text("Profile Setup")
                        .font(.system(.title2, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Tell us about yourself")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, 24)

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Name")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.textSecondary)

                            TextField("", text: $name, prompt: Text("e.g. Sarah Thompson").foregroundStyle(Theme.textSecondary.opacity(0.5)))
                                .focused($focusedField, equals: .name)
                                .onSubmit { focusedField = .organisation }
                                .submitLabel(.next)
                                .textContentType(.name)
                                .padding(14)
                                .background(Theme.surface)
                                .foregroundStyle(Theme.textPrimary)
                                .clipShape(.rect(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Theme.surfaceBorder, lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Organisation")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.textSecondary)

                            TextField("", text: $organisation, prompt: Text("e.g. Aviva, Zurich, Lloyd's").foregroundStyle(Theme.textSecondary.opacity(0.5)))
                                .focused($focusedField, equals: .organisation)
                                .submitLabel(.done)
                                .textContentType(.organizationName)
                                .padding(14)
                                .background(Theme.surface)
                                .foregroundStyle(Theme.textPrimary)
                                .clipShape(.rect(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Theme.surfaceBorder, lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Line of Business Focus")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.textSecondary)

                            HStack(spacing: 8) {
                                ForEach(lobOptions, id: \.self) { option in
                                    Button {
                                        lineOfBusiness = option
                                    } label: {
                                        Text(option)
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(lineOfBusiness == option ? .white : Theme.textSecondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(lineOfBusiness == option ? Theme.accent : Theme.surface)
                                            .clipShape(.rect(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(lineOfBusiness == option ? Theme.accent : Theme.surfaceBorder, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                }
                .scrollDismissesKeyboard(.interactively)

                VStack(spacing: 0) {
                    Button {
                        onContinue()
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isValid ? Theme.accent : Theme.accent.opacity(0.3))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .disabled(!isValid)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { focusedField = .name }
    }
}

struct StepIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...total, id: \.self) { step in
                Capsule()
                    .fill(step <= current ? Theme.accent : Theme.surfaceBorder)
                    .frame(width: step == current ? 28 : 12, height: 4)
                    .animation(.spring(duration: 0.3), value: current)
            }
        }
        .padding(.bottom, 12)
    }
}
