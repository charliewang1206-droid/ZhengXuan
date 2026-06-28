import SwiftData
import SwiftUI

struct ExploreView: View {
    @Query private var items: [ZXItem]

    var body: some View {
        List {
            Section("想尝试") {
                if wishItems.isEmpty {
                    EmptyListRow(title: "还没有想尝试的条目", systemImage: "sparkle")
                } else {
                    ForEach(wishItems.prefix(5), id: \.id) { item in
                        PlaceholderRow(title: item.name, systemImage: "sparkle", detail: item.primaryCategory?.name)
                    }
                }
            }

            Section("重新发现") {
                EmptyListRow(title: "历史记录多起来后，这里会浮出旧选择", systemImage: "archivebox")
            }
        }
        .navigationTitle(AppText.Tab.explore)
    }

    private var wishItems: [ZXItem] {
        items.filter { $0.isWishToTry && !$0.isArchived }
    }
}
