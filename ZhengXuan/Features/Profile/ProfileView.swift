import SwiftUI

struct ProfileView: View {
    var body: some View {
        List {
            Section(AppConfiguration.displayName) {
                NavigationLink {
                    TagManagementView()
                } label: {
                    PlaceholderRow(title: "标签管理", systemImage: "tag")
                }
                NavigationLink {
                    SearchView()
                } label: {
                    PlaceholderRow(title: "搜索", systemImage: "magnifyingglass")
                }
                PlaceholderRow(title: "数据统计", systemImage: "chart.pie")
                PlaceholderRow(title: "数据导出", systemImage: "square.and.arrow.up")
                PlaceholderRow(title: "数据导入", systemImage: "square.and.arrow.down")
            }

            Section("设置") {
                PlaceholderRow(title: "App 设置", systemImage: "gearshape")
                PlaceholderRow(title: "隐私说明", systemImage: "lock.shield")
                PlaceholderRow(title: "关于本 App", systemImage: "info.circle", detail: AppConfiguration.internalProjectName)
            }
        }
        .navigationTitle(AppText.Tab.profile)
    }
}
