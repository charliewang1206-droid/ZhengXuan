import SwiftData
import SwiftUI

struct CategoryListView: View {
    @Query(sort: \ZXCategory.sortOrder) private var categories: [ZXCategory]

    var body: some View {
        List {
            Section {
                if rootCategories.isEmpty {
                    EmptyListRow(title: AppText.Empty.noCategories, systemImage: "folder")
                } else {
                    ForEach(rootCategories, id: \.id) { category in
                        NavigationLink {
                            CategoryDetailPlaceholderView(category: category)
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
        }
        .navigationTitle(AppText.Tab.categories)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("新建分类")
            }
        }
    }

    private var rootCategories: [ZXCategory] {
        categories
            .filter { $0.parentCategory == nil && !$0.isArchived }
            .sorted { $0.sortOrder == $1.sortOrder ? $0.createdAt < $1.createdAt : $0.sortOrder < $1.sortOrder }
    }
}

private struct CategoryDetailPlaceholderView: View {
    let category: ZXCategory

    var body: some View {
        List {
            Section("分类") {
                PlaceholderRow(title: category.name, systemImage: category.iconName, detail: category.note)
                PlaceholderRow(title: "\(category.activeItemCount) 个条目", systemImage: "shippingbox")
                PlaceholderRow(title: "\(category.ratingFields.count) 个评价字段", systemImage: "slider.horizontal.3")
            }

            Section("子分类") {
                if category.childCategories.isEmpty {
                    EmptyListRow(title: "还没有子分类", systemImage: "folder")
                } else {
                    ForEach(category.childCategories, id: \.id) { child in
                        PlaceholderRow(title: child.name, systemImage: child.iconName)
                    }
                }
            }
        }
        .navigationTitle(category.name)
    }
}

