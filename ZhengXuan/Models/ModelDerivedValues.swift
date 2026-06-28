import Foundation

extension String {
    var trimmedForStorage: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension ZXCategory {
    var displayNote: String? {
        guard let note, !note.trimmedForStorage.isEmpty else { return nil }
        return note
    }

    var sortedChildCategories: [ZXCategory] {
        childCategories
            .filter { !$0.isArchived }
            .sorted { lhs, rhs in
                lhs.sortOrder == rhs.sortOrder ? lhs.createdAt < rhs.createdAt : lhs.sortOrder < rhs.sortOrder
            }
    }

    var sortedRatingFields: [RatingFieldDefinition] {
        ratingFields.sorted { lhs, rhs in
            lhs.sortOrder == rhs.sortOrder ? lhs.createdAt < rhs.createdAt : lhs.sortOrder < rhs.sortOrder
        }
    }

    var activePrimaryItems: [ZXItem] {
        primaryItems
            .filter { !$0.isArchived }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func containsDescendant(_ possibleDescendant: ZXCategory) -> Bool {
        childCategories.contains { child in
            child.id == possibleDescendant.id || child.containsDescendant(possibleDescendant)
        }
    }
}

extension ZXItem {
    var categoryPathText: String {
        let primary = primaryCategory?.name
        let secondary = secondaryCategory?.name

        switch (primary, secondary) {
        case let (.some(primary), .some(secondary)):
            return "\(primary) > \(secondary)"
        case let (.some(primary), .none):
            return primary
        case let (.none, .some(secondary)):
            return secondary
        case (.none, .none):
            return "未分类"
        }
    }

    var tagText: String {
        let names = tags.map(\.name).sorted()
        return names.isEmpty ? "无标签" : names.joined(separator: "、")
    }
}

