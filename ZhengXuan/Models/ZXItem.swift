import Foundation
import SwiftData

@Model
final class ZXItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var note: String?
    var createdAt: Date
    var updatedAt: Date
    var firstExperiencedAt: Date?
    var lastExperiencedAt: Date?
    var isFavorite: Bool
    var isWishToTry: Bool
    var isArchived: Bool
    var coverImagePath: String?
    var sortOrder: Int

    var primaryCategory: ZXCategory?

    var secondaryCategory: ZXCategory?

    @Relationship(deleteRule: .nullify, inverse: \ZXTag.items)
    var tags: [ZXTag]

    @Relationship(deleteRule: .cascade, inverse: \ExperienceRecord.item)
    var experienceRecords: [ExperienceRecord]

    init(
        id: UUID = UUID(),
        name: String,
        note: String? = nil,
        primaryCategory: ZXCategory? = nil,
        secondaryCategory: ZXCategory? = nil,
        isFavorite: Bool = false,
        isWishToTry: Bool = false,
        isArchived: Bool = false,
        coverImagePath: String? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.note = note
        self.primaryCategory = primaryCategory
        self.secondaryCategory = secondaryCategory
        self.createdAt = .now
        self.updatedAt = .now
        self.firstExperiencedAt = nil
        self.lastExperiencedAt = nil
        self.isFavorite = isFavorite
        self.isWishToTry = isWishToTry
        self.isArchived = isArchived
        self.coverImagePath = coverImagePath
        self.sortOrder = sortOrder
        self.tags = []
        self.experienceRecords = []
    }

    var isExperienced: Bool {
        !experienceRecords.isEmpty
    }

    var experienceCount: Int {
        experienceRecords.count
    }

    var averageFeelingScore: Double? {
        guard !experienceRecords.isEmpty else { return nil }
        let total = experienceRecords.reduce(0) { $0 + $1.overallFeeling.score }
        return total / Double(experienceRecords.count)
    }

    var latestRecord: ExperienceRecord? {
        experienceRecords.sorted { $0.experiencedAt > $1.experiencedAt }.first
    }

    func touch() {
        updatedAt = .now
    }
}
