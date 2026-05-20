import SwiftUI

struct ScheduleTab: View {
    @Environment(AppState.self) private var state
    @State private var showingFilters = false
    @State private var showingSettings = false
    @State private var selected: Tournament? = nil
    @State private var appeared = false

    var body: some View {
        @Bindable var bindable = state

        NavigationStack {
            VStack(spacing: 0) {
                // Custom screen header (AppSheetHeader-style, no dismiss button)
                screenHeader

                // Search field
                AppSearchField(query: $bindable.filters.search)
                    .padding(.horizontal, AppSpacing.l)
                    .padding(.top, AppSpacing.s)
                    .padding(.bottom, AppSpacing.s)

                // Day-grouped list
                List {
                    ForEach(grouped(), id: \.0) { day, items in
                        Section {
                            ForEach(Array(items.enumerated()), id: \.element.id) { idx, t in
                                Button {
                                    selected = t
                                    AppHaptics.eventOpened()
                                } label: {
                                    EventRow(tournament: t,
                                             venue: state.venue(slug: t.venue),
                                             isStarred: state.isStarred(t.id))
                                }
                                .buttonStyle(.plain)
                                .appRowStyle()
                                .modifier(RowEnterTransition(index: idx, appeared: $appeared))
                            }
                        } header: {
                            AppDayHeader(date: day)
                                .padding(.horizontal, AppSpacing.l)
                                .padding(.top, AppSpacing.s)
                                .listRowInsets(EdgeInsets())
                                .background(AppColor.appBackground)
                        }
                    }
                }
                .listStyle(.plain)
                .listSectionSeparator(.hidden)
                .scrollContentBackground(.hidden)
                .background(AppColor.appBackground)
                .refreshable { await state.refresh() }
                .tint(AppColor.Foil.bright)
                .task {
                    // Trigger the staggered enter once per cold tab open
                    if !appeared {
                        try? await Task.sleep(nanoseconds: 50_000_000)  // 50ms after first frame
                        appeared = true
                    }
                }
            }
            .background(AppColor.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingFilters) {
                FiltersSheet().environment(state)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsSheet().environment(state)
            }
            .sheet(item: $selected) { t in
                EventDetail(tournament: t).environment(state)
            }
        }
    }

    /// Custom header (replaces .navigationTitle). Display-font title, gear left, filters right, foil hairline.
    private var screenHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: AppSpacing.m) {
                AppToolbar.gearButton { showingSettings = true }
                Spacer()
                Text("SCHEDULE")
                    .font(AppFont.sectionLabel)
                    .tracking(2.0)
                    .foregroundStyle(AppColor.Foil.bright)
                Spacer()
                AppToolbar.filtersButton(activeCount: state.filters.activeCount) {
                    showingFilters = true
                }
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.vertical, AppSpacing.m)

            // Large display title beneath the toolbar
            HStack {
                Text("Schedule")
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.Text.primary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.bottom, AppSpacing.s)

            AppHairline.divider(opacity: 0.6)
        }
    }

    private func grouped() -> [(Date, [Tournament])] {
        let cal = Calendar(identifier: .gregorian)
        var byDay: [Date: [Tournament]] = [:]
        for t in state.filtered() {
            let start = cal.startOfDay(for: t.datePT)
            byDay[start, default: []].append(t)
        }
        return byDay.keys.sorted().map { ($0, byDay[$0]!) }
    }
}
