import SwiftData
import SwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let item: ZXItem

    @State private var showingEditor = false
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
                } else {
                    EmptyListRow(title: "还没有体验记录", systemImage: "square.and.pencil")
                }
            }

            Section {
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
        .confirmationDialog("删除后无法恢复。体验记录会随条目一起删除。", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("删除条目", role: .destructive) {
                modelContext.delete(item)
                dismiss()
            }
            Button("取消", role: .cancel) {}
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
}

