import Foundation
import SwiftData

@Model
final class ZXTag {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorIdentifier: String
    var iconName: String
    var createdAt: Date
    var updatedAt: Date

    var items: [ZXItem]

    var experienceRecords: [ExperienceRecord]

    init(
        id: UUID = UUID(),
        name: String,
        colorIdentifier: String = "teal",
        iconName: String = "tag"
    ) {
        self.id = id
        self.name = name
        self.colorIdentifier = colorIdentifier
        self.iconName = iconName
        self.createdAt = .now
        self.updatedAt = .now
        self.items = []
        self.experienceRecords = []
    }

    func touch() {
        updatedAt = .now
    }
}
