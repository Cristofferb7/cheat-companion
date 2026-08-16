import SwiftUI
import CheatKit

struct SettingsView: View {
    let library: GameLibrary

    @AppStorage("appearance") private var appearanceRaw = Appearance.system.rawValue
    @AppStorage("howItWorksDismissed") private var howItWorksDismissed = false
    @Environment(\.dismiss) private var dismiss

    private var totalCodes: Int {
        library.games.map(\.codes.count).reduce(0, +)
    }

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $appearanceRaw) {
                        ForEach(Appearance.allCases) { option in
                            Label(option.label, systemImage: option.iconName)
                                .tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Help") {
                    if howItWorksDismissed {
                        Button("Show “How it works” again") {
                            howItWorksDismissed = false
                            dismiss()
                        }
                    } else {
                        Text("The “How it works” card is shown on the home screen.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    LabeledContent("Version", value: version)
                    LabeledContent("Library",
                                   value: "\(library.games.count) games · \(totalCodes) codes")
                } header: {
                    Text("About")
                } footer: {
                    Text("""
                    Every code carries the source it was verified from and the date. \
                    Codes can still misbehave on some ROMs and emulators — read each \
                    code's warnings, save before enabling anything, and never save \
                    while a glitch is on screen.

                    Cheat Companion is a fan-made tool. It is not affiliated with \
                    Nintendo, The Pokémon Company, or the Delta emulator.
                    """)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
