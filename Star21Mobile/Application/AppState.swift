//
//  AppState.swift
//  Star21Mobile
//
//  Created by Jason Tse on 6/11/2023.
//

import SwiftUI
import Combine

final class AppState {
    @Published var session: AsyncSnapshot<SessionEntity> = .nothing
    @Published var activeRequest: AsyncSnapshot<any RequestEntity> = .nothing
//    @Published var uploadAttachments: [UploadAttachmentEntity] = []
    @Published var requests: AsyncSnapshot<[OnlineRequestEntity]> = .nothing
    @Published var ticketForms: AsyncSnapshot<[TicketFormEntity]> = .nothing
    @Published var showLoading = false
    @Published var authenticationState: AuthenticationState = .mobileChallenge(token: "") // fast
    @Published var formState: FormState? {
        didSet {
            print("old values: \(oldValue?.values.map { "\($0.field.title): \($0.value?.raw())" })")
            print("new values: \(formState?.values.map { "\($0.field.title): \($0.value?.raw())" })")
            print("conditions: \(formState?.conditionsMet.map { "\($0.parent.title): \($0.value.raw())" })")
            print(formState?.displayFields.map { "\($0.title):\($0.type)"})
        }
    }
}

struct FormState {
    let form: TicketFormEntity
    let isAppDisplayForm: Bool
    var conditionsMet: [TicketFormCondition] {
        get {
            form.conditions.filter { condition in
                values.contains(where: { value in
                    value.field == condition.parent && value.value == condition.value
                })
            }
        }
    }
    var fieldsWithCondition: [TicketFieldEntity] {
        get {
            form.fields
                .filter { field in
                    form.conditions.contains(where: { condition in
                        condition.children.contains(where: { child in
                            child == field
                        })
                    })
                }
        }
    }
    var hiddenFields: [TicketFieldEntity] {
        get {
            form.fields
                .filter { field in
                    form.conditions.contains(where: { condition in
                        condition.children.contains(where: { child in
                            child == field
                        })
                    }) && !form.conditions
                        .filter { condition in
                            condition.value == values.first(where: { $0.field == condition.parent })?.value
                        }
                        .flatMap { $0.children }
                        .contains(where: { $0 == field })
                }

        }
    }
    var appAvailableFields: [TicketFieldEntity] {
        get {
            form.fields
                .filter({
                    if isAppDisplayForm {
                        switch $0.type {
                        case .subject, .description: return false
                        case .status, .group, .assignee, .customStatus: return false
                        default: return true
                        }
                    }
                    return true
                })
        }
    }
    var displayFields: [TicketFieldEntity] {
        get {
            appAvailableFields.filter {
                !fieldsWithCondition.contains($0) || conditionsMet.flatMap { $0.children }.contains($0)
            }
        }
    }
    var values: [CustomFieldValueEntity] = []
    var attachments: [UploadAttachmentEntity] = []
    var status: FormStatus = .active
}

enum FormStatus: Hashable {
    case active
    case busy
    case submitted(OnlineRequestEntity)
}
