import SwiftData
import SwiftUI

struct SearchView: View {
    @Query(sort: \ZXItem.name) private var items: [ZXItem]
    @Query(sort: \ZXCategory.name) private var categories: [ZXCategory]
    @Query(sort: \ZXTag.name) private var tags: [ZXTag]

    @State private var query = ""

    var body: some View {
        List {
            Section("条目") {
                if matchingItems.isEmpty {
                    EmptyListRow(title: query.isEmpty ? "输入关键词搜索条目" : "没有匹配条目", systemImage: "shippingbox")
                } else {
                    ForEach(matchingItems, id: \.id) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            PlaceholderRow(title: item.name, systemImage: "shippingbox", detail: item.categoryPathText)
                        }
                    }
                }
            }

            Section("分类") {
                if matchingCategories.isEmpty {
                    EmptyListRow(title: query.isEmpty ? "也可以搜索分类" : "没有匹配分类", systemImage: "folder")
                } else {
                    ForEach(matchingCategories, id: \.id) { category in
                        NavigationLink {
                            CategoryDetailView(category: category)
                        } label: {
                            PlaceholderRow(title: category.name, systemImage: category.iconName, detail: category.displayNote)
                        }
                    }
                }
            }

            Section("标签") {
                if matchingTags.isEmpty {
                    EmptyListRow(title: query.isEmpty ? "也可以搜索标签" : "没有匹配标签", systemImage: "tag")
                } else {
                    ForEach(matchingTags, id: \.id) { tag in
                        PlaceholderRow(title: tag.name, systemImage: tag.iconName)
                    }
                }
            }
        }
        .navigationTitle("搜索")
        .searchable(text: $query, prompt: "搜索条目、分类、标签")
    }

    private var normalizedQuery: String {
        query.trimmedForStorage.localizedLowercase
    }

    private var matchingItems: [ZXItem] {
        guard !normalizedQuery.isEmpty else { return [] }
        return items
            .filter { !$0.isArchived }
            .filter { item in
                item.name.localizedLowercase.contains(normalizedQuery)
                    || item.categoryPathText.localizedLowercase.contains(normalizedQuery)
                    || item.tagText.localizedLowercase.contains(normalizedQuery)
                    || (item.note?.localizedLowercase.contains(normalizedQuery) ?? false)
            }
    }

    private var matchingCategories: [ZXCategory] {
        guard !normalizedQuery.isEmpty else { return [] }
        return categories
            .filter { !$0.isArchived }
            .filter { category in
                category.name.localizedLowercase.contains(normalizedQuery)
                    || (category.note?.localizedLowercase.contains(normalizedQuery) ?? false)
            }
    }

    private var matchingTags: [ZXTag] {
        guard !normalizedQuery.isEmpty else { return [] }
        return tags.filter { $0.name.localizedLowercase.contains(normalizedQuery) }
    }
}

