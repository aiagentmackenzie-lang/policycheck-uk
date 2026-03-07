import Foundation

@MainActor
struct AnalysisService {
    static func analyseCase(
        policyText: String,
        claimText: String,
        lineOfBusiness: String,
        useSimulated: Bool
    ) async throws -> Analysis {
        if useSimulated {
            return try await simulatedAnalysis(policyText: policyText, claimText: claimText, lineOfBusiness: lineOfBusiness)
        } else {
            return try await simulatedAnalysis(policyText: policyText, claimText: claimText, lineOfBusiness: lineOfBusiness)
        }
    }

    private static func simulatedAnalysis(
        policyText: String,
        claimText: String,
        lineOfBusiness: String
    ) async throws -> Analysis {
        let policyLower = policyText.lowercased()
        let claimLower = claimText.lowercased()

        try await Task.sleep(for: .milliseconds(800))
        let level1 = generateLevel1(policyLower: policyLower, claimLower: claimLower)

        try await Task.sleep(for: .milliseconds(1200))
        let level2 = generateLevel2(policyLower: policyLower, claimLower: claimLower, lineOfBusiness: lineOfBusiness)

        try await Task.sleep(for: .milliseconds(1000))
        let level3 = generateLevel3(claimLower: claimLower)

        try await Task.sleep(for: .milliseconds(600))

        let overallVerdict: OverallVerdict
        let confidence: Int

        if level1.verdict == .fail {
            overallVerdict = .notCovered
            confidence = 88
        } else if level2.verdict == .fail {
            overallVerdict = .notCovered
            confidence = 82
        } else if level1.verdict == .pass && level2.verdict == .pass && level3.verdict == .pass {
            overallVerdict = .covered
            confidence = 74
        } else if level2.verdict == .ambiguous || level3.verdict == .ambiguous {
            overallVerdict = .ambiguous
            confidence = 51
        } else {
            overallVerdict = .escalate
            confidence = 45
        }

        let relevantSections = [
            "Insurance Act 2015 s.3 — Duty of fair presentation",
            "FCA ICOBS 8.1 — Claims handling",
            "Consumer Insurance Act 2012 s.5",
            "Insurance Act 2015 s.11 — Proportionate remedies",
            "FCA ICOBS 8.1.1R — Fair handling"
        ]

        return Analysis(
            level1Eligibility: level1,
            level2Coverage: level2,
            level3Compliance: level3,
            overallVerdict: overallVerdict,
            confidence: confidence,
            relevantSections: relevantSections,
            generatedAt: ISO8601DateFormatter().string(from: Date()),
            isSimulated: true
        )
    }

    private static func generateLevel1(policyLower: String, claimLower: String) -> LevelResult {
        let hasExpiredPolicy = policyLower.contains("expired") || policyLower.contains("lapsed")
        let hasExcludedTerritory = policyLower.contains("excluded territory") || policyLower.contains("territorial exclusion")

        if hasExpiredPolicy {
            return LevelResult(
                label: "Eligibility Check",
                verdict: .fail,
                reasoning: "The policy appears to have expired or lapsed prior to the date of loss. The insured may not have had active cover at the time of the incident. This requires verification of the exact policy period against the date of the claim event.",
                flaggedClauses: ["Policy period expired", "Cover not in force at date of loss"]
            )
        } else if hasExcludedTerritory {
            return LevelResult(
                label: "Eligibility Check",
                verdict: .fail,
                reasoning: "The claim arises from an incident in a territory excluded under the policy schedule. The territorial scope clause explicitly limits cover to the United Kingdom.",
                flaggedClauses: ["Excluded territory", "Territorial scope limitation"]
            )
        }

        return LevelResult(
            label: "Eligibility Check",
            verdict: .pass,
            reasoning: "The policy was in force at the material time. The insured party is a named policyholder, and the claim has been submitted within the notification period specified in the policy schedule. No preliminary eligibility barriers have been identified.",
            flaggedClauses: []
        )
    }

    private static func generateLevel2(policyLower: String, claimLower: String, lineOfBusiness: String) -> LevelResult {
        let hasFloodClaim = claimLower.contains("flood") || claimLower.contains("water damage")
        let hasFloodExclusion = policyLower.contains("flood exclusion") || policyLower.contains("flood is excluded")
        let hasTheft = claimLower.contains("theft") || claimLower.contains("stolen") || claimLower.contains("burglary")
        let hasTheftExclusion = policyLower.contains("theft exclusion") || policyLower.contains("theft is excluded")
        let hasFire = claimLower.contains("fire") || claimLower.contains("arson")

        if hasFloodClaim && hasFloodExclusion {
            return LevelResult(
                label: "Coverage Analysis",
                verdict: .fail,
                reasoning: "The claim relates to flood damage, however the policy wording contains an explicit flood exclusion clause. Clause 4.2 states that loss or damage caused by or resulting from flood, including overflow of any body of water, is excluded from cover. This exclusion appears to apply directly to the circumstances described in the claim.",
                flaggedClauses: ["Clause 4.2 — Flood exclusion applies", "Peril not covered under standard wording"]
            )
        } else if hasTheft && !hasTheftExclusion {
            return LevelResult(
                label: "Coverage Analysis",
                verdict: .pass,
                reasoning: "The claim relates to theft, which is a named peril under the policy schedule. No specific exclusions relating to theft have been identified in the policy wording. The circumstances described appear to fall within the standard theft cover provisions, subject to the policy excess and any applicable conditions precedent.",
                flaggedClauses: []
            )
        } else if hasFire {
            return LevelResult(
                label: "Coverage Analysis",
                verdict: .pass,
                reasoning: "Fire is a standard insured peril under this policy. The claim scenario describes fire damage which falls within the scope of cover. Standard fire exclusions (e.g., arson by the insured) do not appear to apply based on the information provided.",
                flaggedClauses: []
            )
        } else if hasFloodClaim && !hasFloodExclusion {
            return LevelResult(
                label: "Coverage Analysis",
                verdict: .ambiguous,
                reasoning: "The claim relates to flood damage. While no explicit flood exclusion has been identified, the policy wording is unclear on whether flood is a named peril or falls within the standard perils clause. Recommend obtaining clarification from the underwriter on the scope of the 'all risks' or 'named perils' basis.",
                flaggedClauses: ["Unclear peril coverage — flood", "Recommend underwriter clarification"]
            )
        }

        return LevelResult(
            label: "Coverage Analysis",
            verdict: .ambiguous,
            reasoning: "The policy wording is unclear on whether this specific peril or circumstance is covered. The claims scenario does not clearly match any named peril or exclusion in the policy schedule. Further investigation and potentially underwriter input is recommended before a definitive coverage determination.",
            flaggedClauses: ["Policy wording ambiguous on this peril", "Recommend escalation to senior handler"]
        )
    }

    private static func generateLevel3(claimLower: String) -> LevelResult {
        let hasMisrepresentation = claimLower.contains("misrepresentation") || claimLower.contains("non-disclosure")

        if hasMisrepresentation {
            return LevelResult(
                label: "Statutory & Regulatory Compliance",
                verdict: .ambiguous,
                reasoning: "Potential non-disclosure or misrepresentation issues have been flagged. Under the Insurance Act 2015, the duty of fair presentation applies. The insurer must demonstrate that any non-disclosure was a qualifying breach before reducing or avoiding the claim. FCA ICOBS 8.1 requires fair claims handling throughout. The Consumer Insurance Act 2012 applies if the insured is a consumer.",
                flaggedClauses: [
                    "Insurance Act 2015 s.3 — Duty of fair presentation",
                    "Consumer Insurance Act 2012 s.4 — Qualifying misrepresentation",
                    "FCA ICOBS 8.1.1R — Fair and prompt handling"
                ]
            )
        }

        return LevelResult(
            label: "Statutory & Regulatory Compliance",
            verdict: .pass,
            reasoning: "No immediate statutory or regulatory compliance issues identified. The claim handling process should continue to comply with FCA ICOBS 8 requirements for fair and prompt handling. The insurer's duty under the Insurance Act 2015 to apply proportionate remedies (s.11) should be observed if any coverage issues arise. Consumer duty obligations under the FCA's Consumer Duty rules also apply.",
            flaggedClauses: [
                "FCA ICOBS 8.1 — Ongoing compliance required",
                "Insurance Act 2015 s.11 — Proportionate remedies"
            ]
        )
    }

    static func extractTextFromImage(lineOfBusiness: String) -> String {
        switch lineOfBusiness {
        case "Property":
            return """
            PROPERTY INSURANCE POLICY — SCHEDULE OF COVER
            Policy Reference: PRO-2024-48291
            Period of Insurance: 01/01/2025 to 31/12/2025

            Section 1 — Buildings Cover
            Sum Insured: £450,000
            Excess: £500 per claim

            Insured Perils: Fire, lightning, explosion, aircraft impact, earthquake, storm, \
            flood (subject to Clause 4.2), theft, malicious damage, escape of water from \
            fixed pipes and tanks, subsidence, heave and landslip.

            Clause 4.2 — Flood Exclusion
            Loss or damage caused by or resulting from flood, including the overflow of any \
            natural or artificial body of water, is EXCLUDED from this policy unless the \
            Flood Extension Endorsement (FEE-01) has been purchased and is noted on the schedule.

            Clause 5.1 — Conditions Precedent
            The insured must maintain the property in a reasonable state of repair. Failure \
            to do so may invalidate a claim under this section.

            Territorial Scope: United Kingdom only.
            """
        case "Motor":
            return """
            MOTOR INSURANCE CERTIFICATE
            Policy Reference: MOT-2025-17834
            Period of Insurance: 15/03/2025 to 14/03/2026
            
            Named Driver(s): John Smith (DOB: 15/04/1985), Jane Smith (DOB: 22/09/1988)
            Vehicle: 2022 BMW 320d, Registration: AB22 CDE
            
            Cover Type: Comprehensive
            
            Compulsory Excess: £350
            Voluntary Excess: £150
            
            Section A — Loss or Damage to Vehicle
            Cover for accidental damage, fire, theft, and attempted theft.
            Maximum claim value: Market value at time of loss.
            
            Section B — Third Party Liability
            Cover for legal liability to third parties for bodily injury and property damage.
            Limit: Unlimited for bodily injury, £20,000,000 for property damage.
            
            Exclusions:
            - Use for hire or reward
            - Racing, rallying, or speed testing
            - Driving under the influence of alcohol or drugs
            - Use outside the United Kingdom and EU
            - Mechanical or electrical breakdown
            """
        case "Liability":
            return """
            PUBLIC LIABILITY INSURANCE
            Policy Reference: PL-2025-93847
            Period of Insurance: 01/04/2025 to 31/03/2026
            
            Policyholder: ABC Services Ltd
            Business Description: Commercial cleaning services
            
            Limit of Indemnity: £5,000,000 any one occurrence
            Excess: £1,000 each and every third party property damage claim
            
            Cover: Legal liability for accidental bodily injury to third parties \
            and accidental damage to third party property arising in connection \
            with the policyholder's business activities.
            
            Territorial Scope: United Kingdom, Channel Islands, Isle of Man
            
            Exclusions:
            - Professional negligence or advice
            - Product liability (covered under separate section)
            - Asbestos-related claims
            - Pollution (unless sudden and unforeseen)
            - Contractual liability beyond common law
            - Claims arising from work at heights exceeding 15 metres
            """
        default:
            return """
            INSURANCE POLICY — GENERAL SCHEDULE
            Policy Reference: GEN-2025-55102
            Period of Insurance: 01/01/2025 to 31/12/2025
            
            This policy provides cover as detailed in the attached schedule \
            and is subject to the general terms, conditions, and exclusions \
            set out herein. The insured should read all documents carefully \
            and contact the insurer if any details are incorrect.
            
            General Exclusions:
            - War, terrorism, and nuclear risks
            - Wear and tear, gradual deterioration
            - Pre-existing damage or defects
            - Deliberate acts by the insured
            """
        }
    }

    static func extractClaimText(lineOfBusiness: String) -> String {
        switch lineOfBusiness {
        case "Property":
            return """
            CLAIM NOTIFICATION — PROPERTY DAMAGE
            Claim Reference: CLM-2025-00482
            Date of Loss: 14/02/2025
            
            Description of Loss:
            Following severe rainfall and rising river levels on 13-14 February 2025, \
            flood water entered the ground floor of the insured property at 42 Riverside \
            Close, Oxford, OX1 4DP. Water damage to flooring, walls (up to 1.2m height), \
            kitchen units, and stored personal effects. The insured was unable to occupy \
            the property for approximately 3 weeks during remediation.
            
            Estimated Claim Value: £78,000
            - Building repairs: £52,000
            - Contents damage: £18,000
            - Alternative accommodation: £8,000
            
            Supporting Documents:
            - Loss adjuster report (attached)
            - Photographs of damage (attached)
            - Contractor estimates x2 (attached)
            - Environment Agency flood alert records
            """
        case "Motor":
            return """
            CLAIM NOTIFICATION — MOTOR THEFT
            Claim Reference: CLM-2025-01293
            Date of Loss: 22/01/2025
            
            Description of Loss:
            The insured vehicle (2022 BMW 320d, Reg: AB22 CDE) was stolen from the \
            insured's driveway at 15 Elm Street, Manchester, M20 3AB during the night \
            of 21-22 January 2025. The vehicle has not been recovered. The insured \
            discovered the theft at approximately 07:30 on 22 January.
            
            Crime Reference: GMP/2025/0012847
            
            The vehicle was locked with all keys accounted for. No signs of forced \
            entry to the property. CCTV from a neighbouring property shows two \
            individuals approaching the vehicle at 03:14.
            
            Estimated Claim Value: £34,500 (market value)
            
            Supporting Documents:
            - Police crime report reference
            - V5C registration document
            - Spare key surrendered to insurer
            - CCTV footage reference
            """
        case "Liability":
            return """
            CLAIM NOTIFICATION — PUBLIC LIABILITY
            Claim Reference: CLM-2025-02187
            Date of Incident: 08/03/2025
            
            Description of Incident:
            A member of the public (Mrs Patricia Brown, age 67) slipped on a wet floor \
            at the premises of ABC Services Ltd's client (Riverside Shopping Centre) \
            while the insured's employees were carrying out cleaning operations. The \
            claimant sustained a fractured hip and was taken to John Radcliffe Hospital \
            by ambulance.
            
            The claimant alleges that inadequate warning signage was displayed and that \
            the wet area was not properly cordoned off. The insured's employee states \
            that a wet floor sign was placed but may have been moved by a member of \
            the public prior to the incident.
            
            Estimated Claim Value: £45,000 - £85,000
            - Medical expenses and rehabilitation
            - Loss of earnings (claimant is self-employed)
            - Pain and suffering
            - Legal costs
            
            Third Party Solicitors: Claim Direct Ltd, Ref: CD/2025/8847
            """
        default:
            return """
            CLAIM NOTIFICATION
            Claim Reference: CLM-2025-03001
            Date of Loss: 01/03/2025
            
            Description of Loss:
            The insured has notified a claim under the policy for loss arising \
            from circumstances described in the attached documentation. The claim \
            relates to an insured event occurring during the policy period.
            
            Estimated Claim Value: £25,000
            
            Further details to follow.
            """
        }
    }
}
