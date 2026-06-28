import SwiftData
import SwiftUI

struct CategoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ZXCategory.sortOrder) private var categories: [ZXCategory]
    @Query(sort: \ZXItem.createdAt, order: .reverse) private var items: [ZXItem]

    @State private var showingCategoryEditor = false
    @State private var showingItemEditor = false

    var body: some View {
        List {
            Section("分类") {
                if rootCategories.isEmpty {
                    EmptyListRow(title: AppText.Empty.noCategories, systemImage: "folder")
                } else {
                    ForEach(rootCategories, id: \.id) { category in
                        NavigationLink {
                            CategoryDetailView(category: category)
                        } label: {
                            PlaceholderRow(
                                title: category.name,
                                systemImage: category.iconName,
                                detail: "\(category.activeItemCount) 个条目"
                            )
                        }
                    }
                }
            }

            Section("最近条目") {
                if activeItems.isEmpty {
                    EmptyListRow(title: AppText.Empty.noItems, systemImage: "shippingbox")
                } else {
                    ForEach(activeItems.prefix(8), id: \.id) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            PlaceholderRow(title: item.name, systemImage: "shippingbox", detail: item.categoryPathText)
                        }
                    }
                }
            }
        }
        .navigationTitle(AppText.Tab.categories)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    SearchView()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("搜索")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingCategoryEditor = true
                    } label: {
                        Label("新建分类", systemImage: "folder.badge.plus")
                    }

                    Button {
                        showingItemEditor = true
                    } label: {
                        Label("新建条目", systemImage: "shippingbox")
                    }
                } label: {
                    Image(systemName: "plus.circle")
                }
                .accessibilityLabel("新建")
            }
        }
        .sheet(isPresented: $showingCategoryEditor) {
            NavigationStack {
                CategoryEditorView()
            }
        }
        .sheet(isPresented: $showingItemEditor) {
            NavigationStack {
                ItemEditorView()
            }
        }
    }

    private var rootCategories: [ZXCategory] {
        categories
            .filter { $0.parentCategory == nil && !$0.isArchived }
            .sorted { $0.sortOrder == $1.sortOrder ? $0.createdAt < $1.createdAt : $0.sortOrder < $1.sortOrder }
    }

    private var activeItems: [ZXItem] {
        items.filter { !$0.isArchived }
    }
}

struct CategoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let category: ZXCategory

    @State private var showingEditor = false
    @State private var showingChildEditor = false
    @State private var showingFieldEditor = false
    @State private var showingItemEditor = false
    @State private var editingField: RatingFieldDefinition?
    @State private var fieldToDelete: RatingFieldDefinition?
    @State private var showingDeleteDialog = false

    var body: some View {
        List {
            Section("分类") {
                PlaceholderRow(title: category.name, systemImage: category.iconName, detail: category.displayNote)
                PlaceholderRow(title: "\(category.activeItemCount) 个条目", systemImage: "shippingbox")
                PlaceholderRow(title: "\(category.ratingFields.count) 个评价字段", systemImage: "slider.horizontal.3")
            }

            Section("子分类") {
                if category.sortedChildCategories.isEmpty {
                    EmptyListRow(title: "还没有子分类", systemImage: "folder")
                } else {
                    ForEach(category.sortedChildCategories, id: \.id) { child in
                        NavigationLink {
                            CategoryDetailView(category: child)
                        } label: {
                            PlaceholderRow(title: child.name, systemImage: child.iconName, detail: "\(child.activeItemCount) 个条目")
                        }
                    }
                }
            }

            Section("评价模板") {
                if category.sortedRatingFields.isEmpty {
                    EmptyListRow(title: "还没有评价字段", systemImage: "slider.horizontal.3")
                } else {
                    ForEach(category.sortedRatingFields, id: \.id) { field in
                        Button {
                            editingField = field
                        } label: {
                            PlaceholderRow(title: field.name, systemImage: "slider.horizontal.3", detail: field.fieldType.displayName)
                        }
                        .swipeActions {
                            Button("删除", role: .destructive) {
                                fieldToDelete = field
                            }
                        }
                    }
                }
            }

            Section("条目") {
                if category.activePrimaryItems.isEmpty {
                    EmptyListRow(title: "这个分类下还没有条目", systemImage: "shippingbox")
                } else {
                    ForEach(category.activePrimaryItems, id: \.id) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            PlaceholderRow(title: item.name, systemImage: item.isWishToTry ? "sparkle" : "shippingbox", detail: item.tagText)
                        }
                    }
                }
            }

            Section {
                Button("新建子分类") {
                    showingChildEditor = true
                }
                Button("新建评价字段") {
                    showingFieldEditor = true
                }
                Button("新建条目") {
                    showingItemEditor = true
                }
                Button("编辑分类") {
                    showingEditor = true
                }
                Button("删除分类", role: .destructive) {
                    showingDeleteDialog = true
                }
            }
        }
        .navigationTitle(category.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingItemEditor = true
                    } label: {
                        Label("新建条目", systemImage: "shippingbox")
                    }
                    Button {
                        showingFieldEditor = true
                    } label: {
                        Label("新建评价字段", systemImage: "slider.horizontal.3")
                    }
                    Button {
                        showingChildEditor = true
                    } label: {
                        Label("新建子分类", systemImage: "folder.badge.plus")
                    }
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                CategoryEditorView(category: category)
            }
        }
        .sheet(isPresented: $showingChildEditor) {
            NavigationStack {
                CategoryEditorView(presetParent: category)
            }
        }
        .sheet(isPresented: $showingFieldEditor) {
            NavigationStack {
                RatingFieldEditorView(category: category)
            }
        }
        .sheet(isPresented: $showingItemEditor) {
            NavigationStack {
                ItemEditorView(presetCategory: category)
            }
        }
        .sheet(isPresented: editingFieldBinding) {
            if let editingField {
                NavigationStack {
                    RatingFieldEditorView(category: category, field: editingField)
                }
            }
        }
        .confirmationDialog("请选择删除方式。", isPresented: $showingDeleteDialog, titleVisibility: .visible) {
            Button("删除分类，保留其中条目") {
                deleteCategoryKeepingItems()
            }
            Button("连同子分类和条目一起删除", role: .destructive) {
                var deletedItemIds = Set<UUID>()
                deleteCategoryWithContents(category, deletedItemIds: &deletedItemIds)
                dismiss()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("保留条目会把相关条目变为未分类。")
        }
        .confirmationDialog("删除评价字段后，已有记录中的对应字段值也会失去模板。", isPresented: fieldDeleteBinding, titleVisibility: .visible) {
            Button("删除评价字段", role: .destructive) {
                if let fieldToDelete {
                    modelContext.delete(fieldToDelete)
                    category.touch()
                    self.fieldToDelete = nil
                }
            }
            Button("取消", role: .cancel) {
                fieldToDelete = nil
            }
        }
    }

    private var editingFieldBinding: Binding<Bool> {
        Binding {
            editingField != nil
        } set: { isPresented in
            if !isPresented {
                editingField = nil
            }
        }
    }

    private var fieldDeleteBinding: Binding<Bool> {
        Binding {
            fieldToDelete != nil
        } set: { isPresented in
            if !isPresented {
                fieldToDelete = nil
            }
        }
    }

    private func deleteCategoryKeepingItems() {
        for item in category.primaryItems {
            item.primaryCategory = nil
            item.touch()
        }
        for item in category.secondaryItems {
            item.secondaryCategory = nil
            item.touch()
        }
        for child in category.childCategories {
            child.parentCategory = nil
            child.touch()
        }
        modelContext.delete(category)
        dismiss()
    }

    private func deleteCategoryWithContents(_ category: ZXCategory, deletedItemIds: inout Set<UUID>) {
        for child in category.childCategories {
            deleteCategoryWithContents(child, deletedItemIds: &deletedItemIds)
        }

        for item in category.primaryItems + category.secondaryItems {
            guard !deletedItemIds.contains(item.id) else { continue }
            deletedItemIds.insert(item.id)
            modelContext.delete(item)
        }

        modelContext.delete(category)
    }
}
