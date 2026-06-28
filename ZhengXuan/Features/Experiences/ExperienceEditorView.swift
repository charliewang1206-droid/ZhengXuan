import SwiftData
import SwiftUI

struct ExperienceEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ZXItem.name) private var items: [ZXItem]
    @Query(sort: \ZXTag.name) private var tags: [ZXTag]

    private let record: ExperienceRecord?
    private let presetItem: ZXItem?

    @State private var itemId: UUID?
    @State private var experiencedAt: Date
    @State private var overallFeeling: OverallFeeling
    @State private var revisitIntent: RevisitIntent
    @State private var instantNote: String
    @State private var locationText: String
    @State private var priceText: String
    @State private var mood: String
    @State private var contextText: String
    @State private var note: String
    @State private var isSolo: Bool
    @State private var selectedTagIds: Set<UUID>
    @State private var numericValues: [UUID: Double]
    @State private var textValues: [UUID: String]
    @State private var boolValues: [UUID: Bool]
    @State private var selectedOptions: [UUID: Set<String>]
    @State private var errorMessage: String?

    init(record: ExperienceRecord? = nil, presetItem: ZXItem? = nil) {
        self.record = record
        self.presetItem = presetItem
        _itemId = State(initialValue: record?.item?.id ?? presetItem?.id)
        _experiencedAt = State(initialValue: record?.experiencedAt ?? .now)
        _overallFeeling = State(initialValue: record?.overallFeeling ?? .neutral)
        _revisitIntent = State(initialValue: record?.revisitIntent ?? .maybe)
        _instantNote = State(initialValue: record?.instantNote ?? "")
        _locationText = State(initialValue: record?.locationText ?? "")
        _priceText = State(initialValue: record?.price.map { String($0) } ?? "")
        _mood = State(initialValue: record?.mood ?? "")
        _contextText = State(initialValue: record?.contextText ?? "")
        _note = State(initialValue: record?.note ?? "")
        _isSolo = State(initialValue: record?.isSolo ?? false)
        _selectedTagIds = State(initialValue: Set(record?.tags.map(\.id) ?? []))
        _numericValues = State(initialValue: Dictionary(uniqueKeysWithValues: record?.fieldValues.compactMap { value in
            guard let fieldId = value.ratingFieldDefinition?.id, let numericValue = value.numericValue else { return nil }
            return (fieldId, numericValue)
        } ?? []))
        _textValues = State(initialValue: Dictionary(uniqueKeysWithValues: record?.fieldValues.compactMap { value in
            guard let fieldId = value.ratingFieldDefinition?.id, let textValue = value.textValue else { return nil }
            return (fieldId, textValue)
        } ?? []))
        _boolValues = State(initialValue: Dictionary(uniqueKeysWithValues: record?.fieldValues.compactMap { value in
            guard let fieldId = value.ratingFieldDefinition?.id, let boolValue = value.boolValue else { return nil }
            return (fieldId, boolValue)
        } ?? []))
        _selectedOptions = State(initialValue: Dictionary(uniqueKeysWithValues: record?.fieldValues.compactMap { value in
            guard let fieldId = value.ratingFieldDefinition?.id else { return nil }
            return (fieldId, Set(value.selectedOptions))
        } ?? []))
    }

    var body: some View {
        Form {
            Section("这一次") {
                Picker("条目", selection: $itemId) {
                    Text("请选择条目").tag(UUID?.none)
                    ForEach(activeItems, id: \.id) { item in
                        Text(item.name).tag(Optional(item.id))
                    }
                }
                .disabled(presetItem != nil || record != nil)

                DatePicker("体验时间", selection: $experiencedAt)
            }

            Section("快速记录") {
                Picker("总体感觉", selection: $overallFeeling) {
                    ForEach(OverallFeeling.allCases) { feeling in
                        Text(feeling.displayName).tag(feeling)
                    }
                }

                Picker("以后还会选它吗？", selection: $revisitIntent) {
                    ForEach(RevisitIntent.allCases) { intent in
                        Text(intent.displayName).tag(intent)
                    }
                }

                TextField("留下一句当下感受", text: $instantNote, axis: .vertical)
                    .lineLimit(2...4)
            }

            if !dynamicFields.isEmpty {
                Section("分类评价") {
                    ForEach(dynamicFields, id: \.id) { field in
                        fieldInput(field)
                    }
                }
            }

            Section("标签") {
                if tags.isEmpty {
                    Text("还没有标签，可以稍后补。")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(tags, id: \.id) { tag in
                        Toggle(tag.name, isOn: bindingForTag(tag))
                    }
                }
            }

            Section("更多细节") {
                TextField("地点，可选", text: $locationText)
                TextField("价格，可选", text: $priceText)
                    .keyboardType(.decimalPad)
                TextField("心情，可选", text: $mood)
                TextField("当时场景，可选", text: $contextText, axis: .vertical)
                    .lineLimit(2...4)
                Toggle("这次是独自体验", isOn: $isSolo)
                TextField("备注，可选", text: $note, axis: .vertical)
                    .lineLimit(2...5)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(record == nil ? "记录一次体验" : "编辑体验记录")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    save()
                }
            }
        }
    }

    private var activeItems: [ZXItem] {
        items.filter { !$0.isArchived }
    }

    private var selectedItem: ZXItem? {
        activeItems.first { $0.id == itemId } ?? presetItem ?? record?.item
    }

    private var dynamicFields: [RatingFieldDefinition] {
        let categories = [selectedItem?.primaryCategory, selectedItem?.secondaryCategory].compactMap { $0 }
        var seen = Set<UUID>()
        var fields: [RatingFieldDefinition] = []

        for category in categories {
            for field in category.sortedRatingFields where !seen.contains(field.id) {
                seen.insert(field.id)
                fields.append(field)
            }
        }

        return fields
    }

    @ViewBuilder
    private func fieldInput(_ field: RatingFieldDefinition) -> some View {
        switch field.fieldType {
        case .ratingFive:
            Picker(field.name, selection: numericBinding(for: field, defaultValue: 3)) {
                ForEach(1...5, id: \.self) { value in
                    Text("\(value)").tag(Double(value))
                }
            }
        case .ratingTen:
            Picker(field.name, selection: numericBinding(for: field, defaultValue: 5)) {
                ForEach(1...10, id: \.self) { value in
                    Text("\(value)").tag(Double(value))
                }
            }
        case .singleChoice:
            Picker(field.name, selection: textBinding(for: field)) {
                Text("未选择").tag("")
                ForEach(field.options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        case .multiChoice:
            VStack(alignment: .leading) {
                Text(field.name)
                ForEach(field.options, id: \.self) { option in
                    Toggle(option, isOn: optionBinding(for: field, option: option))
                }
            }
        case .boolean:
            Toggle(field.name, isOn: boolBinding(for: field))
        case .shortText, .optionalNote:
            TextField(field.name, text: textBinding(for: field), axis: .vertical)
                .lineLimit(1...3)
        case .number:
            TextField(field.name, text: textNumberBinding(for: field))
                .keyboardType(.decimalPad)
        }
    }

    private func bindingForTag(_ tag: ZXTag) -> Binding<Bool> {
        Binding {
            selectedTagIds.contains(tag.id)
        } set: { isSelected in
            if isSelected {
                selectedTagIds.insert(tag.id)
            } else {
                selectedTagIds.remove(tag.id)
            }
        }
    }

    private func numericBinding(for field: RatingFieldDefinition, defaultValue: Double) -> Binding<Double> {
        Binding {
            numericValues[field.id] ?? defaultValue
        } set: { value in
            numericValues[field.id] = value
        }
    }

    private func textBinding(for field: RatingFieldDefinition) -> Binding<String> {
        Binding {
            textValues[field.id] ?? ""
        } set: { value in
            textValues[field.id] = value
        }
    }

    private func textNumberBinding(for field: RatingFieldDefinition) -> Binding<String> {
        Binding {
            if let value = numericValues[field.id] {
                return String(value)
            }
            return ""
        } set: { value in
            numericValues[field.id] = Double(value.trimmedForStorage)
        }
    }

    private func boolBinding(for field: RatingFieldDefinition) -> Binding<Bool> {
        Binding {
            boolValues[field.id] ?? false
        } set: { value in
            boolValues[field.id] = value
        }
    }

    private func optionBinding(for field: RatingFieldDefinition, option: String) -> Binding<Bool> {
        Binding {
            selectedOptions[field.id, default: []].contains(option)
        } set: { isSelected in
            var options = selectedOptions[field.id, default: []]
            if isSelected {
                options.insert(option)
            } else {
                options.remove(option)
            }
            selectedOptions[field.id] = options
        }
    }

    private func save() {
        guard let selectedItem else {
            errorMessage = "请选择一个条目。"
            return
        }

        let cleanInstantNote = instantNote.trimmedForStorage
        guard !cleanInstantNote.isEmpty else {
            errorMessage = "请留下一句当下感受。"
            return
        }

        for field in dynamicFields where field.isRequired && !hasValue(for: field) {
            errorMessage = "请填写“\(field.name)”。"
            return
        }

        let selectedTags = tags.filter { selectedTagIds.contains($0.id) }
        let price = Double(priceText.trimmedForStorage)

        let savedRecord: ExperienceRecord
        if let record {
            record.item = selectedItem
            record.experiencedAt = experiencedAt
            record.overallFeeling = overallFeeling
            record.revisitIntent = revisitIntent
            record.instantNote = cleanInstantNote
            record.locationText = cleanedOptional(locationText)
            record.price = price
            record.mood = cleanedOptional(mood)
            record.contextText = cleanedOptional(contextText)
            record.note = cleanedOptional(note)
            record.isSolo = isSolo
            record.tags = selectedTags
            record.touch()
            savedRecord = record
        } else {
            let newRecord = ExperienceRecord(
                item: selectedItem,
                experiencedAt: experiencedAt,
                overallFeeling: overallFeeling,
                revisitIntent: revisitIntent,
                instantNote: cleanInstantNote,
                locationText: cleanedOptional(locationText),
                price: price,
                mood: cleanedOptional(mood),
                contextText: cleanedOptional(contextText),
                isSolo: isSolo,
                note: cleanedOptional(note)
            )
            newRecord.tags = selectedTags
            modelContext.insert(newRecord)
            savedRecord = newRecord
        }

        saveFieldValues(for: savedRecord)
        applyTimelineChange(to: selectedItem)
        dismiss()
    }

    private func hasValue(for field: RatingFieldDefinition) -> Bool {
        switch field.fieldType {
        case .ratingFive, .ratingTen:
            return true
        case .number:
            return numericValues[field.id] != nil
        case .singleChoice, .shortText, .optionalNote:
            return !(textValues[field.id]?.trimmedForStorage.isEmpty ?? true)
        case .multiChoice:
            return !(selectedOptions[field.id]?.isEmpty ?? true)
        case .boolean:
            return true
        }
    }

    private func saveFieldValues(for record: ExperienceRecord) {
        for field in dynamicFields {
            let existingValue = record.fieldValues.first { $0.ratingFieldDefinition?.id == field.id }
            let value = existingValue ?? ExperienceFieldValue(experienceRecord: record, ratingFieldDefinition: field)

            value.numericValue = numericValueToSave(for: field)
            value.textValue = cleanedOptional(textValues[field.id] ?? "")
            value.boolValue = boolValues[field.id]
            value.selectedOptions = Array(selectedOptions[field.id] ?? [])
            value.touch()

            if value.experienceRecord == nil {
                value.experienceRecord = record
            }
            if value.ratingFieldDefinition == nil {
                value.ratingFieldDefinition = field
            }
            if existingValue == nil {
                modelContext.insert(value)
            }
        }
    }

    private func numericValueToSave(for field: RatingFieldDefinition) -> Double? {
        switch field.fieldType {
        case .ratingFive:
            return numericValues[field.id] ?? 3
        case .ratingTen:
            return numericValues[field.id] ?? 5
        case .number:
            return numericValues[field.id]
        default:
            return numericValues[field.id]
        }
    }

    private func applyTimelineChange(to item: ZXItem) {
        if item.firstExperiencedAt == nil || experiencedAt < item.firstExperiencedAt! {
            item.firstExperiencedAt = experiencedAt
        }
        if item.lastExperiencedAt == nil || experiencedAt > item.lastExperiencedAt! {
            item.lastExperiencedAt = experiencedAt
        }
        item.isWishToTry = false
        item.touch()
    }

    private func cleanedOptional(_ value: String) -> String? {
        let clean = value.trimmedForStorage
        return clean.isEmpty ? nil : clean
    }
}
