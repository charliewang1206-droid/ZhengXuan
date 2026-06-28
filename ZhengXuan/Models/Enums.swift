import Foundation

enum RatingFieldType: String, CaseIterable, Codable, Identifiable {
    case ratingFive
    case ratingTen
    case singleChoice
    case multiChoice
    case boolean
    case shortText
    case number
    case optionalNote

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ratingFive:
            return "评分 1-5"
        case .ratingTen:
            return "评分 1-10"
        case .singleChoice:
            return "单选"
        case .multiChoice:
            return "多选标签"
        case .boolean:
            return "是 / 否"
        case .shortText:
            return "短文本"
        case .number:
            return "数字"
        case .optionalNote:
            return "可选备注"
        }
    }
}

enum OverallFeeling: String, CaseIterable, Codable, Identifiable {
    case veryDislike
    case dislike
    case neutral
    case like
    case love

    var id: String { rawValue }

    var score: Double {
        switch self {
        case .veryDislike: 1
        case .dislike: 2
        case .neutral: 3
        case .like: 4
        case .love: 5
        }
    }

    var displayName: String {
        switch self {
        case .veryDislike:
            return "很不喜欢"
        case .dislike:
            return "不喜欢"
        case .neutral:
            return "一般"
        case .like:
            return "喜欢"
        case .love:
            return "非常喜欢"
        }
    }
}

enum RevisitIntent: String, CaseIterable, Codable, Identifiable {
    case definitelyYes
    case yes
    case maybe
    case probablyNo
    case no

    var id: String { rawValue }

    var weight: Double {
        switch self {
        case .definitelyYes: 5
        case .yes: 4
        case .maybe: 3
        case .probablyNo: 2
        case .no: 1
        }
    }

    var displayName: String {
        switch self {
        case .definitelyYes:
            return "一定会"
        case .yes:
            return "会"
        case .maybe:
            return "看情况"
        case .probablyNo:
            return "大概率不会"
        case .no:
            return "不会"
        }
    }
}
