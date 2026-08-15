import SwiftUI
import CheatKit

/// The core flow: read the warnings, copy the code (master code first when
/// needed), jump into Delta, paste.
struct CodeDetailView: View {
    let file: GameFile
    let code: CheatCode
    let selectedRevision: String
    let deltaLink: String

    @State private var copiedID: String?

    private var masterCode: CheatCode? {
        guard code.requiresMasterCode, let id = code.masterCodeID else { return nil }
        return file.codes.first { $0.id == id }
    }

    var body: some View {
        List {
            if !code.sideEffects.isEmpty {
                Section {
                    ForEach(code.sideEffects, id: \.self) { effect in
                        Label(effect, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.callout)
                    }
                } header: {
                    Text("Before you use this")
                }
            }

            if let master = masterCode {
                codeSection(master,
                            title: "Step 1 — Master code (add as its own cheat first)",
                            footer: "In Delta, add this as a separate cheat named “Master Code” and enable it. GameShark/Action Replay codes won't work without it.")
            }

            codeSection(code,
                        title: masterCode == nil ? "Code" : "Step 2 — \(code.name)",
                        footer: pasteInstructions)

            if let activation = code.activation {
                Section("In-game activation") {
                    Label(activation, systemImage: "gamecontroller")
                }
            }

            Section("Provenance") {
                LabeledContent("Device", value: code.device.displayName)
                LabeledContent("Region", value: code.region)
                LabeledContent("ROM revision", value: code.romRevision)
                LabeledContent("Reliability",
                               value: code.reliability == .sourceVerified
                                   ? "Verified across sources"
                                   : "Community-reported — test on a fresh save")
                LabeledContent("Last verified", value: code.lastVerified)
                if let url = URL(string: code.sourceURL) {
                    Link("Source page", destination: url)
                }
            }
        }
        .navigationTitle(code.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pasteInstructions: String {
        let launch = deltaLink.isEmpty
            ? "Open Delta and launch the game"
            : "Tap “Open in Delta”"
        return "\(launch), pause → Cheat Codes → + → choose “\(code.device.displayName)” → paste."
    }

    @ViewBuilder
    private func codeSection(_ target: CheatCode, title: String, footer: String) -> some View {
        Section {
            Text(target.code)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)

            Button {
                UIPasteboard.general.string = target.code
                copiedID = target.id
                if !deltaLink.isEmpty, let url = URL(string: deltaLink) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(
                    copiedID == target.id
                        ? "Copied"
                        : (deltaLink.isEmpty ? "Copy code" : "Copy & open in Delta"),
                    systemImage: copiedID == target.id ? "checkmark" : "doc.on.doc"
                )
            }
        } header: {
            Text(title)
        } footer: {
            Text(footer)
        }
    }
}
