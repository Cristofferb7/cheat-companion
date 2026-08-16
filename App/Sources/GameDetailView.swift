import SwiftUI
import CheatKit

/// Per-game screen: pick your ROM revision, optionally attach the game's
/// delta:// deep link (copied from Delta's share sheet), browse codes.
struct GameDetailView: View {
    let file: GameFile

    @AppStorage private var selectedRevision: String
    @AppStorage private var deltaLink: String
    @State private var showLinkHelp = false

    init(file: GameFile) {
        self.file = file
        _selectedRevision = AppStorage(wrappedValue: file.game.revisions.first ?? "unspecified",
                                       "revision.\(file.game.slug)")
        _deltaLink = AppStorage(wrappedValue: "", "deltaLink.\(file.game.slug)")
    }

    private var revisionMismatches: Bool {
        file.game.revisions.count > 1
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    CoverArt(game: file.game, height: 180)
                    HStack(spacing: 8) {
                        chip(file.game.system.displayName)
                        chip(file.game.region)
                        chip("\(file.codes.count) codes")
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            if revisionMismatches {
                Section {
                    Picker("My ROM revision", selection: $selectedRevision) {
                        ForEach(file.game.revisions, id: \.self) { Text($0) }
                        Text("Not sure").tag("unspecified")
                    }
                } footer: {
                    if let note = file.game.revisionNote {
                        Text(note)
                    }
                }
            }

            Section {
                if deltaLink.isEmpty {
                    Button("Add this game's Delta link…") { showLinkHelp = true }
                } else {
                    Label("One-tap launch into Delta is set up", systemImage: "checkmark.circle")
                        .foregroundStyle(.green)
                    Button("Remove Delta link", role: .destructive) { deltaLink = "" }
                }
            } footer: {
                Text("In Delta: long-press the game → Share → Copy Deep Link, then paste it here.")
            }

            Section("Cheat codes") {
                ForEach(file.codes.filter { !$0.isMasterCode }) { code in
                    NavigationLink {
                        CodeDetailView(file: file, code: code,
                                       selectedRevision: selectedRevision,
                                       deltaLink: deltaLink)
                    } label: {
                        CodeRow(code: code, selectedRevision: selectedRevision)
                    }
                }
            }
        }
        .navigationTitle(file.game.title)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.gameColor(for: file.game))
        .sheet(isPresented: $showLinkHelp) {
            DeltaLinkSheet(deltaLink: $deltaLink)
        }
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Theme.gameColor(for: file.game))
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(Theme.gameColor(for: file.game).opacity(0.12), in: Capsule())
    }
}

struct CodeRow: View {
    let code: CheatCode
    let selectedRevision: String

    private var revisionWarning: String? {
        if code.romRevision == "unspecified" {
            return "Source didn't state a ROM revision — test carefully"
        }
        if selectedRevision != "unspecified",
           code.romRevision != selectedRevision,
           !code.romRevision.hasPrefix("CPUE") // DS game IDs aren't revisions
        {
            return "Made for \(code.romRevision), you selected \(selectedRevision)"
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(code.name).font(.body)
            HStack(spacing: 6) {
                Text(code.device.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 5).padding(.vertical, 1)
                    .background(.quaternary, in: Capsule())
                if !code.sideEffects.isEmpty {
                    Label("Caution", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                if code.reliability == .communityReported {
                    Text("Community-reported")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            if let warning = revisionWarning {
                Label(warning, systemImage: "questionmark.circle")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }
}

struct DeltaLinkSheet: View {
    @Binding var deltaLink: String
    @Environment(\.dismiss) private var dismiss
    @State private var pasted = ""
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("1. Open Delta\n2. Long-press this game\n3. Share → Copy Deep Link\n4. Paste it below")
                }
                Section {
                    TextField("delta://game/…", text: $pasted)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if let errorText {
                        Text(errorText).font(.caption).foregroundStyle(.red)
                    }
                    Button("Save") {
                        let trimmed = pasted.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.hasPrefix("delta://"), URL(string: trimmed) != nil {
                            deltaLink = trimmed
                            dismiss()
                        } else {
                            errorText = "That doesn't look like a delta:// link."
                        }
                    }
                }
            }
            .navigationTitle("Link to Delta")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
