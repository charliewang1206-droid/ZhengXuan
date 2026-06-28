import Foundation
import SwiftData

@Model
final class ExperienceRecord {
    @Attribute(.unique) var id: UUID
    var experiencedAt: Date
    var overallFeelingRawValue: String
    var revisitIntentRawValue: String
    var instantNote: String
    var locationText: String?
    var price: Double?
    var mood: String?
    var contextText: String?
    var isSolo: Bool?
    var imagePaths: [String]
    var note: String?
    var createdAt: Date
    var updatedAt: Date

    var item: ZXItem?

    @Relationship(deleteRule: .nullify, inverse: \ZXTag.experienceRecords)
    var tags: [ZXTag]

    @Relationship(deleteRule: .cascade, inverse: \ExperienceFieldValue.experienceRecord)
    var fieldValues: [ExperienceFieldValue]

    init(
        id: UUID = UUID(),
        item: ZXItem? = nil,
        experiencedAt: Date = .now,
        overallFeeling: OverallFeeling = .neutral,
        revisitIntent: RevisitIntent = .maybe,
        instantNote: String,
        locationText: String? = nil,
        price: Double? = nil,
        mood: String? = nil,
        contextText: String? = nil,
        isSolo: Bool? = nil,
        imagePaths: [String] = [],
        note: String? = nil
    ) {
        self.id = id
        self.item = item
        self.experiencedAt = experiencedAt
        self.overallFeelingRawValue = overallFeeling.rawValue
        self.revisitIntentRawValue = revisitIntent.rawValue
        self.instantNote = instantNote
        self.locationText = locationText
        self.price = price
        self.mood = mood
        self.contextText = contextText
        self.isSolo = isSolo
        self.imagePaths = imagePaths
        self.note = note
        self.createdAt = .now
        self.updatedAt = .now
        self.tags = []
        self.fieldValues = []
    }

    var overallFeeling: OverallFeeling {
        get { OverallFeeling(rawValue: overallFeelingRawValue) ?? .neutral }
        set {
            overallFeelingRawValue = newValue.rawValue
            touch()
        }
    }

    var revisitIntent: RevisitIntent {
        get { RevisitIntent(rawValue: revisitIntentRawValue) ?? .maybe }
        set {
            revisitIntentRawValue = newValue.rawValue
            touch()
        }
    }

    func touch() {
        updatedAt = .now
    }
}
