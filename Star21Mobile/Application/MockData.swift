//
//  MockData.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import Foundation

struct MockData {

    static let field: TicketFieldEntity = .init(
        id: 1,
        title: "Mock Field",
        description: "Mock Description",
        type: .text,
        required: false,
        options: nil,
        regexForValidation: nil,
        tags: []
    )

    static let onlineTicket: OnlineRequestEntity = .init(
        id: 1234,
        subject: "Mock Subject",
        description: "Mock Description",
        status: .pending,
        ticketForm: .init(
            id: 1,
            name: "Mock Form",
            fields: [MockData.field],
            conditions: []
        ),
        customFields: [],
        priority: .normal,
        createdAt: Date(),
        updatedAt: Date(),
        comments: [
            MockData.comment
        ]
    )

    static let comment: CommentEntity = .init(
        id: 1,
        body: "Comment Body",
        author: "Author User",
        organization: "Author Organization",
        isAgent: false,
        createdAt: Date(),
        attachments: []
    )

    static let custom: CustomFieldValueEntity = .init(
        field: MockData.field,
        value: .bool(true)
    )
}
