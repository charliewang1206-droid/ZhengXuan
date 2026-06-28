import SwiftData
import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab
    @Query(sort: \ExperienceRecord.experiencedAt, order: .reverse) private var recentRecords: [ExperienceRecord]
    @Query(sort: \ZXItem.createdAt, order: .reverse) private var recentItems: [ZXItem]
    @State private var showingQuickRecord = false

    var body: some View {
        List {
            Section {
                Button {
                    showingQuickRecord = true
                } label: {
                    Label(AppText.Action.quickRecord, systemImage: "square.and.pencil")
                        .font(.headline)
                }

                Button {
                    selectedTab = .decision
                } label: {
                    Label(AppText.Action.decide, systemImage: "sparkle.magnifyingglass")
                        .font(.headline)
                }
            }

            Section("最近记录") {
                if recentRecords.isEmpty {
                    EmptyListRow(title: AppText.Empty.noRecords, systemImage: "clock")
                } else {
                    ForEach(recentRecords.prefix(5), id: \.id) { record in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(record.item?.name ?? "未命名条目")
                                .font(.body.weight(.medium))
                            Text(record.instantNote)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            Text(record.experiencedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section("最近添加") {
                if activeRecentItems.isEmpty {
                    EmptyListRow(title: AppText.Empty.noItems, systemImage: "tray")
                } else {
                    ForEach(activeRecentItems.prefix(5), id: \.id) { item in
                        PlaceholderRow(
                            title: item.name,
                            systemImage: item.isWishToTry ? "sparkle" : "bookmark",
                            detail: item.primaryCategory?.name
                        )
                    }
                }
            }

            Section("一点概览") {
                PlaceholderRow(title: "本周记录 \(recordsThisWeek) 次", systemImage: "calendar")
                PlaceholderRow(title: "本月记录 \(recordsThisMonth) 次", systemImage: "chart.line.uptrend.xyaxis")
            }
        }
        .navigationTitle(AppConfiguration.displayName)
        .sheet(isPresented: $showingQuickRecord) {
            NavigationStack {
                ContentUnavailableView(
                    "还没有可记录的条目",
                    systemImage: "square.and.pencil",
                    description: Text("先建立分类和条目后，就能在这里快速留下体验。")
                )
                .navigationTitle(AppText.Action.quickRecord)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("完成") {
                            showingQuickRecord = false
                        }
                    }
                }
            }
        }
    }

    private var recordsThisWeek: Int {
        let calendar = Calendar.current
        return recentRecords.filter { calendar.isDate($0.experiencedAt, equalTo: .now, toGranularity: .weekOfYear) }.count
    }

    private var recordsThisMonth: Int {
        let calendar = Calendar.current
        return recentRecords.filter { calendar.isDate($0.experiencedAt, equalTo: .now, toGranularity: .month) }.count
    }

    private var activeRecentItems: [ZXItem] {
        recentItems.filter { !$0.isArchived }
    }
}
