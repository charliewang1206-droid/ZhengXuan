import SwiftData
import SwiftUI

struct CategoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ZXCategory.sortOrder) private var categories: [ZXCategory]

    private let category: ZXCategory?
    private let presetParent: ZXCategory?

    @State private var name: String
    @State private var iconName: String
    @State private var colorIdentifier: String
    @State private var note: String
    @State private var parentCategoryId: UUID?
    @State private var errorMessage: String?

    init(category: ZXCategory? = nil, presetParent: ZXCategory? = nil) {
        self.category = category
        self.presetParent = presetParent
        _name = State(initialValue: category?.name ?? "")
        _iconName = State(initialValue: category?.iconName ?? "folder")
        _colorIdentifier = State(initialValue: category?.colorIdentifier ?? "teal")
        _note = State(initialValue: category?.note ?? "")
        _parentCategoryId = State(initialValue: category?.parentCategory?.id ?? presetParent?.id)
    }

    var body: some View {
        Form {
            Section("基础信息") {
                TextField("分类名称", text: $name)
                Picker("图标", selection: $iconName) {
                    ForEach(iconChoices, id: \.systemName) { icon in
                        Label(icon.displayName, systemImage: icon.systemName)
                            .tag(icon.systemName)
                    }
                }
                Picker("颜色标识", selection: $colorIdentifier) {
                    ForEach(colorChoices, id: \.self) { color in
                        Text(color.displayName)
                            .tag(color.rawValue)
                    }
                }
                TextField("说明，可选", text: $note, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("层级") {
                Picker("父分类", selection: $parentCategoryId) {
                    Text("无，作为一级分类").tag(UUID?.none)
                    ForEach(parentCandidates, id: \.id) { candidate in
                        Text(candidate.name).tag(Optional(candidate.id))
                    }
                }
                .disabled(presetParent != nil)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(category == nil ? "新建分类" : "编辑分类")
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

    private var parentCandidates: [ZXCategory] {
        categories.filter { candidate in
            guard !candidate.isArchived else { return false }
            guard candidate.id != category?.id else { return false }
            if let category, category.containsDescendant(candidate) {
                return false
            }
            return true
        }
    }

    private func save() {
        let cleanName = name.trimmedForStorage
        guard !cleanName.isEmpty else {
            errorMessage = "分类名称不能为空。"
            return
        }

        let parent = parentCandidates.first { $0.id == parentCategoryId }
        let cleanNote = note.trimmedForStorage

        if let category {
            category.name = cleanName
            category.iconName = iconName
            category.colorIdentifier = colorIdentifier
            category.note = cleanNote.isEmpty ? nil : cleanNote
            category.parentCategory = presetParent ?? parent
            category.touch()
        } else {
            let nextSortOrder = (categories.map(\.sortOrder).max() ?? 0) + 1
            let newCategory = ZXCategory(
                name: cleanName,
                iconName: iconName,
                colorIdentifier: colorIdentifier,
                parentCategory: presetParent ?? parent,
                sortOrder: nextSortOrder,
                note: cleanNote.isEmpty ? nil : cleanNote
            )
            modelContext.insert(newCategory)
        }

        dismiss()
    }
}

private struct IconChoice {
    let systemName: String
    let displayName: String
}

private let iconChoices = [
    IconChoice(systemName: "folder", displayName: "文件夹"),
    IconChoice(systemName: "fork.knife", displayName: "食物"),
    IconChoice(systemName: "cup.and.saucer", displayName: "饮品"),
    IconChoice(systemName: "airplane", displayName: "旅行"),
    IconChoice(systemName: "house", displayName: "生活"),
    IconChoice(systemName: "shippingbox", displayName: "物品"),
    IconChoice(systemName: "sparkles", displayName: "探索")
]

private enum CategoryColorChoice: String, CaseIterable {
    case teal
    case blue
    case green
    case orange
    case purple
    case gray

    var displayName: String {
        switch self {
        case .teal:
            return "青色"
        case .blue:
            return "蓝色"
        case .green:
            return "绿色"
        case .orange:
            return "橙色"
        case .purple:
            return "紫色"
        case .gray:
            return "灰色"
        }
    }
}

private let colorChoices = CategoryColorChoice.allCases
