import SwiftUI

struct SettingsSheet: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var showingHelp = false

    var body: some View {
        VStack(spacing: 0) {
            AppSheetHeader(title: "Settings", onDismiss: { dismiss() })

            ScrollView {
                VStack(spacing: AppSpacing.l) {
                    helpSection
                    feedSection
                    warningsSection
                    sourceSection
                    aboutSection
                }
                .padding(AppSpacing.l)
            }
            .background(AppColor.appBackground)
        }
        .background(AppColor.appBackground.ignoresSafeArea())
        .sheet(isPresented: $showingHelp) {
            HelpSheet()
        }
    }

    // MARK: - Help

    private var helpSection: some View {
        SectionCard(title: "HELP") {
            Button {
                showingHelp = true
            } label: {
                HStack(spacing: AppSpacing.s) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColor.Foil.bright)
                    Text("HOW TO USE")
                        .font(AppFont.sectionLabel)
                        .tracking(1.2)
                        .foregroundStyle(AppColor.Foil.bright)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.Foil.muted)
                }
                .padding(.horizontal, AppSpacing.m)
                .padding(.vertical, AppSpacing.s)
                .background(AppColor.Foil.bright.opacity(0.08), in: RoundedRectangle(cornerRadius: AppRadius.chip))
                .overlay(RoundedRectangle(cornerRadius: AppRadius.chip)
                    .strokeBorder(AppColor.Foil.bright.opacity(0.5), lineWidth: 0.8))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Feed

    private var feedSection: some View {
        SectionCard(title: "FEED") {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                HStack(alignment: .firstTextBaseline) {
                    Text("LAST UPDATED")
                        .font(AppFont.sectionLabel)
                        .tracking(1.4)
                        .foregroundStyle(AppColor.Text.secondary)
                    Spacer()
                    Text(state.lastUpdated.map(format(_:)) ?? "Never (bundled seed)")
                        .font(AppFont.timestamp)
                        .foregroundStyle(AppColor.Text.primary)
                }

                if let err = state.refreshError {
                    HStack(alignment: .top, spacing: AppSpacing.s) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColor.State.urgent)
                        Text(err)
                            .font(AppFont.meta)
                            .foregroundStyle(AppColor.State.urgent)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, AppSpacing.xs)
                }

                AppButton(
                    state.isRefreshing ? "REFRESHING…" : "REFRESH NOW",
                    systemImage: "arrow.clockwise",
                    style: .primary
                ) {
                    Task {
                        await state.refresh()
                        AppHaptics.refreshComplete()
                    }
                }
                .disabled(state.isRefreshing)
                .padding(.top, AppSpacing.s)
            }
        }
    }

    // MARK: - Warnings

    private var warningsSection: some View {
        SectionCard(title: "DATA WARNINGS") {
            HStack(spacing: AppSpacing.s) {
                if state.parseWarningCount == 0 {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColor.State.success)
                    Text("No parse warnings — latest pipeline run is clean.")
                        .font(AppFont.bodyCopy)
                        .foregroundStyle(AppColor.Text.primary)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColor.State.warning)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(state.parseWarningCount) row(s) failed to parse cleanly")
                            .font(AppFont.bodyCopy)
                            .foregroundStyle(AppColor.Text.primary)
                        Text("Source sheet may have changed format — pipeline will pick it up on next run.")
                            .font(AppFont.meta)
                            .foregroundStyle(AppColor.Text.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Source

    private var sourceSection: some View {
        SectionCard(title: "SOURCE") {
            VStack(spacing: AppSpacing.s) {
                Link(destination: URL(string: "https://x.com/SpaceyFCB/")!) {
                    sourceRow(label: "SCHEDULE BY @SPACEYFCB", systemImage: "person.crop.square")
                }
                .buttonStyle(.plain)
                Link(destination: URL(string: "https://ko-fi.com/spaceyfcb")!) {
                    sourceRow(label: "SUPPORT ON KO-FI", systemImage: "heart.fill")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func sourceRow(label: String, systemImage: String) -> some View {
        HStack(spacing: AppSpacing.s) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColor.Foil.bright)
            Text(label)
                .font(AppFont.sectionLabel)
                .tracking(1.2)
                .foregroundStyle(AppColor.Foil.bright)
            Spacer()
            Image(systemName: "arrow.up.right.square")
                .font(.system(size: 12))
                .foregroundStyle(AppColor.Foil.muted)
        }
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.s)
        .background(AppColor.Foil.bright.opacity(0.08), in: RoundedRectangle(cornerRadius: AppRadius.chip))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.chip)
            .strokeBorder(AppColor.Foil.bright.opacity(0.5), lineWidth: 0.8))
    }

    // MARK: - About

    private var aboutSection: some View {
        SectionCard(title: "ABOUT") {
            Text("Kenny's List is a personal-use app. Tournament data is fetched from a public Google Sheet maintained by SpaceyFCB. Not affiliated with any venue.")
                .font(AppFont.notesBody)
                .foregroundStyle(AppColor.Text.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Helpers

    private func format(_ d: Date) -> String {
        let f = RelativeDateTimeFormatter()
        return f.localizedString(for: d, relativeTo: Date())
    }
}
