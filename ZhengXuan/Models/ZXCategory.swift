import Foundation
import SwiftData

@Model
final class ZXCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconName: String
    var colorIdentifier: String
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date
    var note: String?
    var isArchived: Bool

    var parentCategory: ZXCategory?

    @Relationship(deleteRule: .nullify, inverse: \ZXCategory.parentCategory)
    var childCategories: [ZXCategory]

    @Relationship(deleteRule: .nullify, inverse: \ZXItem.primaryCategory)
    var primaryItems: [ZXItem]

    @Relationship(deleteRule: .nullify, inverse: \ZXItem.secondaryCategory)
    var secondaryItems: [ZXItem]

    @Relationship(deleteRule: .cascade, inverse: \RatingFieldDefinition.category)
    var ratingFields: [RatingFieldDefinition]

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "folder",
        colorIdentifier: String = "teal",
        parentCategory: ZXCategory? = nil,
        sortOrder: Int = 0,
        note: String? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorIdentifier = colorIdentifier
        self.parentCategory = parentCategory
        self.sortOrder = sortOrder
        self.createdAt = .now
        self.updatedAt = .now
        self.note = note
        self.isArchived = isArchived
        self.childCategories = []
        self.primaryItems = []
        self.secondaryItems = []
        self.ratingFields = []
    }

    var activeItemCount: Int {
        primaryItems.filter { !$0.isArchived }.count + secondaryItems.filter { !$0.isArchived }.count
    }

    func touch() {
        updatedAt = .now
    }
}
