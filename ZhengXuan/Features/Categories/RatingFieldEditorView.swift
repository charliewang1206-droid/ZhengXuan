import SwiftData
import SwiftUI

struct RatingFieldEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let category: ZXCategory
    private let field: RatingFieldDefinition?

    @State private var name: String
    @State private var fieldType: RatingFieldType
    @State private var optionsText: String
    @State private var isRequired: Bool
    @State private var errorMessage: String?

    init(category: ZXCategory, field: RatingFieldDefinition? = nil) {
        self.category = category
        self.field = field
        _name = State(initialValue: field?.name ?? "")
        _fieldType = State(initialValue: field?.fieldType ?? .ratingFive)
        _optionsText = State(initialValue: field?.options.joined(separator: "\n") ?? "")
        _isRequired = State(initialValue: field?.isRequired ?? false)
    }

    var body: some View {
        Form {
            Section("字段") {
                TextField("字段名称", text: $name)
                Picker("字段类型", selection: $fieldType) {
                    ForEach(RatingFieldType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                Toggle("必填", isOn: $isRequired)
            }

            if fieldType == .singleChoice || fieldType == .multiChoice {
                Section("选项") {
                    TextField("每行一个选项", text: $optionsText, axis: .vertical)
                        .lineLimit(3...8)
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(field == nil ? "新建评价字段" : "编辑评价字段")
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

    private func save() {
        let cleanName = name.trimmedForStorage
        guard !cleanName.isEmpty else {
            errorMessage = "字段名称不能为空。"
            return
        }

        let options = optionsText
            .components(separatedBy: .newlines)
            .map(\.trimmedForStorage)
            .filter { !$0.isEmpty }

        if (fieldType == .singleChoice || fieldType == .multiChoice), options.isEmpty {
            errorMessage = "单选或多选字段至少需要一个选项。"
            return
        }

        if let field {
            field.name = cleanName
            field.fieldType = fieldType
            field.options = options
            field.isRequired = isRequired
            field.touch()
        } else {
            let nextSortOrder = (category.ratingFields.map(\.sortOrder).max() ?? 0) + 1
            let newField = RatingFieldDefinition(
                category: category,
                name: cleanName,
                fieldType: fieldType,
                options: options,
                isRequired: isRequired,
                sortOrder: nextSortOrder
            )
            modelContext.insert(newField)
        }

        category.touch()
        dismiss()
    }
}

