import SwiftUI

struct DecisionView: View {
    var body: some View {
        List {
            Section("当前想要") {
                PlaceholderRow(title: "稳妥", systemImage: "checkmark.seal")
                PlaceholderRow(title: "探索", systemImage: "sparkles")
                PlaceholderRow(title: "随机", systemImage: "shuffle")
                PlaceholderRow(title: "重温很久没选的好东西", systemImage: "clock.arrow.circlepath")
            }

            Section("推荐结果") {
                EmptyListRow(title: "有了条目和记录后，这里会给出推荐理由", systemImage: "text.bubble")
            }
        }
        .navigationTitle(AppText.Tab.decision)
    }
}

