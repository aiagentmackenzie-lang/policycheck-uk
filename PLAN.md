# PolicyCheck UK — Compliance Co-Pilot for UK Insurance Professionals

## Features

- **Onboarding flow** — 3-step first-launch experience: welcome screen with app branding, profile setup (name, organisation, line of business), and analysis mode selection (simulated or live AI)
- **Active Cases dashboard** — View all active cases with status filters (All / Pending / Analysed / Awaiting Review), colour-coded verdict badges, and quick access to case details
- **New Case wizard** — 3-step guided flow: enter case details, upload/paste policy and claim documents (with mock OCR scanning), then run analysis with animated progress
- **4-Level AI Analysis** — Eligibility check, coverage analysis, regulatory compliance (citing UK legislation like Insurance Act 2015, FCA ICOBS), and human review — displayed as expandable cards with verdict pills
- **Human Review** — Bottom sheet to agree, disagree, or override AI analysis with rationale and reviewer name
- **Case History** — All cases grouped by date with search, verdict chips, and review status
- **Settings** — Profile editing, analysis engine toggle (simulated/live), API key management, data export, and clear all cases
- **Simulated AI analysis** — Realistic mock responses based on document keywords (flood exclusions, theft coverage, etc.) with UK regulatory references
- **Local persistence** — All data stored on device using UserDefaults/JSON encoding
- **Export** — Share plain text case summaries via the iOS share sheet
- **Haptic feedback** — Throughout the app for interactions, verdicts, and submissions

## Design

- **Dark professional theme** — Deep dark background (#0D0F14), dark surface cards (#161B22), electric blue accent (#2F80ED)
- **Colour-coded verdicts** — Green for COVERED, red for NOT_COVERED, amber for AMBIGUOUS, red outline for ESCALATE
- **Cards with subtle borders** — 12pt corner radius, thin border styling, soft depth
- **Expandable analysis cards** — Smooth accordion animations for the 4-level analysis
- **Native iOS feel** — SF Symbols throughout, system-style navigation, haptic feedback
- **UK English spelling** — "behaviour", "authorised", "analyse" throughout

## Screens

- **Welcome Screen** — Full-screen dark card with shield icon, tagline "Scan. Analyse. Decide. Defend.", and "Get Started" button
- **Profile Setup Screen** — Name, organisation, and line of business picker
- **Analysis Mode Screen** — Two selectable cards for simulated vs live AI mode, with optional API key input
- **Cases Tab** — Active cases list with filter bar, case cards showing status/verdict, and empty state
- **New Case Tab** — 3-step wizard with progress bar: case details → document upload → run analysis
- **History Tab** — Date-grouped case list with search bar
- **Settings Tab** — Profile, analysis engine, data management, and about sections
- **Case Detail Screen** — Full case view with documents, analysis results, and human review
- **Human Review Sheet** — Bottom sheet with decision tiles, rationale input, and submit button
- **Analysis Loading Screen** — Animated sequential status messages during analysis

## App Icon

- Dark navy/black background with a shield shape in electric blue (#2F80ED), containing a white checkmark, suggesting compliance and protection — professional and authoritative

