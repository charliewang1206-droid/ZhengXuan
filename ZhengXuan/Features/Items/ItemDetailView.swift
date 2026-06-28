import SwiftData
import SwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let item: ZXItem

    @State private var showingEditor = false
    @State private var showingExperienceEditor = false
    @State private var editingRecord: ExperienceRecord?
    @State private var deletingRecord: ExperienceRecord?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: item.isFavorite ? "star.fill" : "shippingbox")
                            .foregroundStyle(item.isFavorite ? .yellow : AppTheme.accent)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.title3.weight(.semibold))
                            Text(item.categoryPathText)
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                    }

                    if let note = item.note, !note.trimmedForStorage.isEmpty {
                        Text(note)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("状态") {
                Toggle("收藏", isOn: favoriteBinding)
                Toggle("想尝试", isOn: wishBinding)
                Toggle("归档", isOn: archivedBinding)
            }

            Section("标签") {
                if item.tags.isEmpty {
                    EmptyListRow(title: "还没有标签", systemImage: "tag")
                } else {
                    ForEach(item.tags.sorted { $0.name < $1.name }, id: \.id) { tag in
                        PlaceholderRow(title: tag.name, systemImage: tag.iconName)
                    }
                }
            }

            Section("体验概览") {
                PlaceholderRow(title: "\(item.experienceCount) 次体验", systemImage: "clock")
                if let score = item.averageFeelingScore {
                    PlaceholderRow(title: String(format: "平均满意度 %.1f / 5", score), systemImage: "star")
                }
                if let latestRecord = item.latestRecord {
                    PlaceholderRow(title: latestRecord.instantNote, systemImage: "quote.bubble", detail: latestRecord.experiencedAt.formatted(date: .abbreviated, time: .omitted))
                } else {
                    EmptyListRow(title: "还没有体验记录", systemImage: "square.and.pencil")
                }
            }

            Section("历史记录") {
                if sortedExperienceRecords.isEmpty {
                    EmptyListRow(title: "记录一次体验后，这里会显示历史", systemImage: "clock")
                } else {
                    ForEach(sortedExperienceRecords, id: \.id) { record in
                        Button {
                            editingRecord = record
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(record.overallFeeling.displayName)
                                        .font(.body.weight(.medium))
                                    Spacer()
                                    Text(record.revisitIntent.displayName)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Text(record.instantNote)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                Text(record.experiencedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions {
                            Button("删除", role: .destructive) {
                                deletingRecord = record
                            }
                        }
                    }
                }
            }

            Section {
                Button("添加一次新的体验") {
                    showingExperienceEditor = true
                }

                Button("编辑条目") {
                    showingEditor = true
                }

                Button("删除条目", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .navigationTitle(item.name)
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                ItemEditorView(item: item)
            }
        }
        .sheet(isPresented: $showingExperienceEditor) {
            NavigationStack {
                ExperienceEditorView(presetItem: item)
            }
        }
        .sheet(isPresented: editingRecordBinding) {
            if let editingRecord {
                NavigationStack {
                    ExperienceEditorView(record: editingRecord)
                }
            }
        }
        .confirmationDialog("删除后无法恢复。体验记录会随条目一起删除。", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("删除条目", role: .destructive) {
                modelContext.delete(item)
                dismiss()
            }
            Button("取消", role: .cancel) {}
        }
        .confirmationDialog("删除这条体验记录后无法恢复。", isPresented: deletingRecordBinding, titleVisibility: .visible) {
            Button("删除记录", role: .destructive) {
                if let deletingRecord {
                    deleteRecord(deletingRecord)
                    self.deletingRecord = nil
                }
            }
            Button("取消", role: .cancel) {
                deletingRecord = nil
            }
        }
    }

    private var favoriteBinding: Binding<Bool> {
        Binding {
            item.isFavorite
        } set: { newValue in
            item.isFavorite = newValue
            item.touch()
        }
    }

    private var wishBinding: Binding<Bool> {
        Binding {
            item.isWishToTry
        } set: { newValue in
            item.isWishToTry = newValue
            item.touch()
        }
    }

    private var archivedBinding: Binding<Bool> {
        Binding {
            item.isArchived
        } set: { newValue in
            item.isArchived = newValue
            item.touch()
        }
    }

    private var sortedExperienceRecords: [ExperienceRecord] {
        item.experienceRecords.sorted { $0.experiencedAt > $1.experiencedAt }
    }

    private var editingRecordBinding: Binding<Bool> {
        Binding {
            editingRecord != nil
        } set: { isPresented in
            if !isPresented {
                editingRecord = nil
            }
        }
    }

    private var deletingRecordBinding: Binding<Bool> {
        Binding {
            deletingRecord != nil
        } set: { isPresented in
            if !isPresented {
                deletingRecord = nil
            }
        }
    }

    private func deleteRecord(_ record: ExperienceRecord) {
        let remainingDates = item.experienceRecords
            .filter { $0.id != record.id }
            .map(\.experiencedAt)

        item.firstExperiencedAt = remainingDates.min()
        item.lastExperiencedAt = remainingDates.max()
        item.touch()
        modelContext.delete(record)
    }
}
