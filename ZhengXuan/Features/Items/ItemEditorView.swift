import SwiftData
import SwiftUI

struct ItemEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ZXCategory.sortOrder) private var categories: [ZXCategory]
    @Query(sort: \ZXTag.name) private var tags: [ZXTag]

    private let item: ZXItem?
    private let presetCategory: ZXCategory?

    @State private var name: String
    @State private var note: String
    @State private var primaryCategoryId: UUID?
    @State private var secondaryCategoryId: UUID?
    @State private var isFavorite: Bool
    @State private var isWishToTry: Bool
    @State private var selectedTagIds: Set<UUID>
    @State private var errorMessage: String?

    init(item: ZXItem? = nil, presetCategory: ZXCategory? = nil) {
        self.item = item
        self.presetCategory = presetCategory
        _name = State(initialValue: item?.name ?? "")
        _note = State(initialValue: item?.note ?? "")
        _primaryCategoryId = State(initialValue: item?.primaryCategory?.id ?? presetCategory?.id)
        _secondaryCategoryId = State(initialValue: item?.secondaryCategory?.id)
        _isFavorite = State(initialValue: item?.isFavorite ?? false)
        _isWishToTry = State(initialValue: item?.isWishToTry ?? false)
        _selectedTagIds = State(initialValue: Set(item?.tags.map(\.id) ?? []))
    }

    var body: some View {
        Form {
            Section("基础信息") {
                TextField("条目名称", text: $name)
                TextField("备注，可选", text: $note, axis: .vertical)
                    .lineLimit(2...5)
            }

            Section("分类") {
                Picker("主分类", selection: $primaryCategoryId) {
                    Text("未分类").tag(UUID?.none)
                    ForEach(activeCategories, id: \.id) { category in
                        Text(category.name).tag(Optional(category.id))
                    }
                }
                .disabled(presetCategory != nil)

                Picker("子分类", selection: $secondaryCategoryId) {
                    Text("无").tag(UUID?.none)
                    ForEach(activeCategories, id: \.id) { category in
                        Text(category.name).tag(Optional(category.id))
                    }
                }
            }

            Section("状态") {
                Toggle("收藏", isOn: $isFavorite)
                Toggle("想尝试", isOn: $isWishToTry)
            }

            Section("标签") {
                if tags.isEmpty {
                    Text("还没有标签，可以先在“我的 > 标签管理”里创建。")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(tags, id: \.id) { tag in
                        Toggle(tag.name, isOn: bindingForTag(tag))
                    }
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(item == nil ? "新建条目" : "编辑条目")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    save()
                }
            }
        }
    }

    private var activeCategories: [ZXCategory] {
        categories.filter { !$0.isArchived }
    }

    private func bindingForTag(_ tag: ZXTag) -> Binding<Bool> {
        Binding {
            selectedTagIds.contains(tag.id)
        } set: { isSelected in
            if isSelected {
                selectedTagIds.insert(tag.id)
            } else {
                selectedTagIds.remove(tag.id)
            }
        }
    }

    private func save() {
        let cleanName = name.trimmedForStorage
        guard !cleanName.isEmpty else {
            errorMessage = "条目名称不能为空。"
            return
        }

        let primaryCategory = activeCategories.first { $0.id == primaryCategoryId }
        let secondaryCategory = activeCategories.first { $0.id == secondaryCategoryId }
        let selectedTags = tags.filter { selectedTagIds.contains($0.id) }
        let cleanNote = note.trimmedForStorage

        if let item {
            item.name = cleanName
            item.note = cleanNote.isEmpty ? nil : cleanNote
            item.primaryCategory = presetCategory ?? primaryCategory
            item.secondaryCategory = secondaryCategory
            item.isFavorite = isFavorite
            item.isWishToTry = isWishToTry
            item.tags = selectedTags
            item.touch()
        } else {
            let newItem = ZXItem(
                name: cleanName,
                note: cleanNote.isEmpty ? nil : cleanNote,
                primaryCategory: presetCategory ?? primaryCategory,
                secondaryCategory: secondaryCategory,
                isFavorite: isFavorite,
                isWishToTry: isWishToTry
            )
            newItem.tags = selectedTags
            modelContext.insert(newItem)
        }

        dismiss()
    }
}

