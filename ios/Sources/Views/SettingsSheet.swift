import SwiftUI

struct SettingsSheet: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Feed") {
                    LabeledContent("Last updated") {
                        Text(state.lastUpdated.map { format($0) } ?? "Never (using bundled seed)")
                            .foregroundStyle(.secondary)
                    }
                    if let err = state.refreshError {
                        Label(err, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                    Button {
                        Task { await state.refresh() }
                    } label: {
                        Label("Refresh now", systemImage: "arrow.clockwise")
                    }
                    .disabled(state.isRefreshing)
                }
                Section("Data warnings") {
                    if state.parseWarningCount == 0 {
                        Label("No parse warnings", systemImage: "checkmark.circle")
                            .foregroundStyle(.green)
                            .font(.footnote)
                    } else {
                        Label("\(state.parseWarningCount) row(s) failed to parse cleanly in the latest pipeline run.", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                            .font(.footnote)
                    }
                }
                Section("Source") {
                    Link("Schedule by SpaceyFCB", destination: URL(string: "https://x.com/SpaceyFCB/")!)
                    Link("Support on Ko-fi", destination: URL(string: "https://ko-fi.com/spaceyfcb")!)
                }
                Section("About") {
                    Text("Vegas Poker Guide — personal use. Data from a public Google Sheet maintained by SpaceyFCB. Not affiliated with any venue.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
    }

    private func format(_ d: Date) -> String {
        let f = RelativeDateTimeFormatter()
        return f.localizedString(for: d, relativeTo: Date())
    }
}
