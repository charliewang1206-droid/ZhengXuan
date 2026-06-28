import Foundation
import SwiftData

@Model
final class ExperienceFieldValue {
    @Attribute(.unique) var id: UUID
    var numericValue: Double?
    var textValue: String?
    var boolValue: Bool?
    var selectedOptions: [String]
    var createdAt: Date
    var updatedAt: Date

    var experienceRecord: ExperienceRecord?

    var ratingFieldDefinition: RatingFieldDefinition?

    init(
        id: UUID = UUID(),
        experienceRecord: ExperienceRecord? = nil,
        ratingFieldDefinition: RatingFieldDefinition? = nil,
        numericValue: Double? = nil,
        textValue: String? = nil,
        boolValue: Bool? = nil,
        selectedOptions: [String] = []
    ) {
        self.id = id
        self.experienceRecord = experienceRecord
        self.ratingFieldDefinition = ratingFieldDefinition
        self.numericValue = numericValue
        self.textValue = textValue
        self.boolValue = boolValue
        self.selectedOptions = selectedOptions
        self.createdAt = .now
        self.updatedAt = .now
    }

    func touch() {
        updatedAt = .now
    }
}
