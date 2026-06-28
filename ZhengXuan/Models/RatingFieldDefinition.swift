import Foundation
import SwiftData

@Model
final class RatingFieldDefinition {
    @Attribute(.unique) var id: UUID
    var name: String
    var fieldTypeRawValue: String
    var options: [String]
    var isRequired: Bool
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date

    var category: ZXCategory?

    @Relationship(deleteRule: .nullify, inverse: \ExperienceFieldValue.ratingFieldDefinition)
    var fieldValues: [ExperienceFieldValue]

    init(
        id: UUID = UUID(),
        category: ZXCategory? = nil,
        name: String,
        fieldType: RatingFieldType,
        options: [String] = [],
        isRequired: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.category = category
        self.name = name
        self.fieldTypeRawValue = fieldType.rawValue
        self.options = options
        self.isRequired = isRequired
        self.sortOrder = sortOrder
        self.createdAt = .now
        self.updatedAt = .now
        self.fieldValues = []
    }

    var fieldType: RatingFieldType {
        get { RatingFieldType(rawValue: fieldTypeRawValue) ?? .shortText }
        set {
            fieldTypeRawValue = newValue.rawValue
            touch()
        }
    }

    func touch() {
        updatedAt = .now
    }
}
