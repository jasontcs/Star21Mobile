//
//  Models+Mapper.swift
//  Star21Mobile
//
//  Created by Jason Tse on 10/11/2023.
//

extension User {
    func toEntity() -> UserEntity {
        .init(
            id: id,
            name: name,
            email: email,
            tags: tags
        )
    }
}

extension Request {
    func toEntity(forms: [TicketFormEntity], fields: [TicketFieldEntity]) throws -> OnlineRequestEntity {
        .init(
            id: id,
            subject: subject,
            description: description,
            status: RequestStatus(rawValue: status)!,
            ticketForm: ticketFormId != nil ? forms.first { $0.id == ticketFormId }! : nil,
            customFields: customFields.map { custom in
                .init(
                    field: fields.first { $0.id == custom.id}!,
                    value: custom.value
                )
            },
            priority: priority,
            createdAt: createdAt,
            updatedAt: updatedAt,
            comments: nil
        )
    }
}

extension DraftRequest {
    static func from(_ value: DraftRequestEntity) -> DraftRequest {
        .init(
            subject: value.subject,
            customFields: value.customFields.map {
                .init(id: $0.id, value: $0.value)
            },
            comment: .init(
                body: value.description,
                uploads: value.uploads.compactMap {
                    if case let .online(token) = $0.status { return token }
                    return nil
                }
            ),
            collaborators: [],
            ticketFormId: value.ticketForm?.id,
            priority: value.priority
        )
    }
}

extension TicketForm {
    func toEntity(fields: [TicketFieldEntity]) throws -> TicketFormEntity {

        let conditions = endUserConditions
            .map { raw in
                TicketFormCondition(
                    parent: fields.first { $0.id == raw.parentFieldID }!,
                    value: raw.value,
                    children: raw.childFields.map { child in
                        fields.first { $0.id == child.id }!
                    }
                )
            }

        return .init(
            id: id,
            name: name,
            fields: ticketFieldIDS.map { id in
                let field = fields.first { $0.id == id }!
                return .init(
                    id: field.id,
                    title: field.title,
                    description: field.description,
                    type: field.type,
                    required: field.required,
                    options: field.options,
                    regexForValidation: field.regexForValidation
                )
            },
            conditions: conditions
        )
    }
}

extension TicketField {
    func toEntity() -> TicketFieldEntity {
        .init(
            id: id,
            title: title,
            description: description,
            type: type,
            required: self.required,
            options: customFieldOptions?.map { $0.toEntity() },
            regexForValidation: regexpForValidation
        )
    }
}

extension CustomFieldOption {
    func toEntity() -> TicketFieldOption {
        .init(
            id: id,
            name: name,
            value: value,
            isDefault: self.isDefault
        )
    }
}

extension Comment {
    func toEntity(users: [CommentUser], organizations: [CommentOrganization]) throws -> CommentEntity {
        let user = users.first { $0.id == authorID }!

        return .init(
            id: id,
            body: body,
            author: user.name,
            organization: organizations.first { $0.id == user.organizationID }!.name,
            isAgent: user.agent,
            createdAt: createdAt,
            attachments: try attachments.map { try $0.toEntity() }
        )
    }
}

extension Upload {
    func toEntity(original: UploadAttachmentEntity) throws -> UploadAttachmentEntity {
        return .init(
            data: original.data,
            status: .online(token: token),
            fileName: attachment.fileName
        )
    }
}

extension Attachment {
    func toEntity() throws -> AttachmentEntity {
        return .init(
            id: id,
            type: .image,
            url: contentURL
        )
    }
}
