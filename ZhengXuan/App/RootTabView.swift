import SwiftUI

enum AppTab: Hashable {
    case home
    case categories
    case decision
    case explore
    case profile
}

struct RootTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label(AppText.Tab.home, systemImage: "house")
            }
            .tag(AppTab.home)

            NavigationStack {
                CategoryListView()
            }
            .tabItem {
                Label(AppText.Tab.categories, systemImage: "square.grid.2x2")
            }
            .tag(AppTab.categories)

            NavigationStack {
                DecisionView()
            }
            .tabItem {
                Label(AppText.Tab.decision, systemImage: "sparkle.magnifyingglass")
            }
            .tag(AppTab.decision)

            NavigationStack {
                ExploreView()
            }
            .tabItem {
                Label(AppText.Tab.explore, systemImage: "safari")
            }
            .tag(AppTab.explore)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label(AppText.Tab.profile, systemImage: "person.crop.circle")
            }
            .tag(AppTab.profile)
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    RootTabView()
}

