import SwiftData
import SwiftUI

@main
struct ZhengXuanApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [
            ZXCategory.self,
            RatingFieldDefinition.self,
            ZXTag.self,
            ZXItem.self,
            ExperienceRecord.self,
            ExperienceFieldValue.self
        ])
    }
}

