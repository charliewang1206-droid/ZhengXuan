import Foundation

enum AppConfiguration {
    static var displayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "正选"
    }

    static let internalProjectName = "ZhengXuan"
    static let minimumSupportedIOSVersion = "17.0"
    static let dataSchemaVersion = 1
}

enum AppText {
    enum Tab {
        static let home = "首页"
        static let categories = "分类"
        static let decision = "帮我选"
        static let explore = "探索"
        static let profile = "我的"
    }

    enum Action {
        static let quickRecord = "刚体验完，记录一下"
        static let decide = "今天想选什么？"
    }

    enum Empty {
        static let noRecords = "还没有体验记录"
        static let noItems = "还没有条目"
        static let noCategories = "还没有分类"
        static let quietStart = "给生活里的选择留一个安静的位置。"
    }
}

