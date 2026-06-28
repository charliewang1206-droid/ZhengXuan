import SwiftData
import SwiftUI

struct TagManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ZXTag.name) private var tags: [ZXTag]

    @State private var showingNewTag = false
    @State private var editingTag: ZXTag?
    @State private var deletingTag: ZXTag?

    var body: some View {
        List {
            Section {
                if tags.isEmpty {
                    EmptyListRow(title: "还没有标签", systemImage: "tag")
                } else {
                    ForEach(tags, id: \.id) { tag in
                        Button {
                            editingTag = tag
                        } label: {
                            PlaceholderRow(
                                title: tag.name,
                                systemImage: tag.iconName,
                                detail: "\(tag.items.count) 个条目，\(tag.experienceRecords.count) 条记录"
                            )
                        }
                        .swipeActions {
                            Button("删除", role: .destructive) {
                                deletingTag = tag
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("标签管理")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewTag = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("新建标签")
            }
        }
        .sheet(isPresented: $showingNewTag) {
            NavigationStack {
                TagEditorView()
            }
        }
        .sheet(isPresented: editingTagBinding) {
            if let editingTag {
                NavigationStack {
                    TagEditorView(tag: editingTag)
                }
            }
        }
        .confirmationDialog("删除标签不会删除条目或体验记录。", isPresented: deletingTagBinding, titleVisibility: .visible) {
            Button("删除标签", role: .destructive) {
                if let deletingTag {
                    modelContext.delete(deletingTag)
                    self.deletingTag = nil
                }
            }
            Button("取消", role: .cancel) {
                deletingTag = nil
            }
        }
    }

    private var deletingTagBinding: Binding<Bool> {
        Binding {
            deletingTag != nil
        } set: { isPresented in
            if !isPresented {
                deletingTag = nil
            }
        }
    }

    private var editingTagBinding: Binding<Bool> {
        Binding {
            editingTag != nil
        } set: { isPresented in
            if !isPresented {
                editingTag = nil
            }
        }
    }
}

private struct TagEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let tag: ZXTag?

    @State private var name: String
    @State private var iconName: String
    @State private var colorIdentifier: String
    @State private var errorMessage: String?

    init(tag: ZXTag? = nil) {
        self.tag = tag
        _name = State(initialValue: tag?.name ?? "")
        _iconName = State(initialValue: tag?.iconName ?? "tag")
        _colorIdentifier = State(initialValue: tag?.colorIdentifier ?? "teal")
    }

    var body: some View {
        Form {
            Section("标签") {
                TextField("标签名称", text: $name)
                Picker("图标", selection: $iconName) {
                    Label("标签", systemImage: "tag").tag("tag")
                    Label("火花", systemImage: "sparkle").tag("sparkle")
                    Label("星标", systemImage: "star").tag("star")
                    Label("月亮", systemImage: "moon").tag("moon")
                    Label("地点", systemImage: "mappin").tag("mappin")
                }
                Picker("颜色标识", selection: $colorIdentifier) {
                    Text("青色").tag("teal")
                    Text("蓝色").tag("blue")
                    Text("绿色").tag("green")
                    Text("橙色").tag("orange")
                    Text("紫色").tag("purple")
                    Text("灰色").tag("gray")
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(tag == nil ? "新建标签" : "编辑标签")
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

    private func save() {
        let cleanName = name.trimmedForStorage
        guard !cleanName.isEmpty else {
            errorMessage = "标签名称不能为空。"
            return
        }

        if let tag {
            tag.name = cleanName
            tag.iconName = iconName
            tag.colorIdentifier = colorIdentifier
            tag.touch()
        } else {
            modelContext.insert(ZXTag(name: cleanName, colorIdentifier: colorIdentifier, iconName: iconName))
        }

        dismiss()
    }
}
